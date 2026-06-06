import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_disclosure_dialog.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/core/models/transactions/transaction.dart';
import 'package:kora_expense_tracker/core/models/accounts/account_type.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import 'package:kora_expense_tracker/features/accounts/account_controller.dart';
import 'package:kora_expense_tracker/core/utils/formatters.dart';

class AddTransactionDialog extends StatefulWidget {
  final Transaction? transaction; // For editing existing transactions
  final String? defaultAccountId; // Pre-select this account
  final String?
  initialType; // Pre-select transaction type (from quick-add drawer)

  const AddTransactionDialog({
    super.key,
    this.transaction,
    this.defaultAccountId,
    this.initialType,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  // ── Controller accessors ──────────────────────────────────────────────────
  TransactionController get _txn => context.read<TransactionController>();
  AccountController get _acc => context.read<AccountController>();

  String _selectedType = AppConstants.transactionTypeExpense;
  String _amount = '';
  String _description = '';
  String _notes = '';

  /// The final category id saved in the transaction (could be sub-category)
  String? _selectedCategoryId;

  /// The parent category id selected in step 1 of category picker
  String? _selectedParentCategoryId;

  /// Optional sub-category selected in step 2 (not mandatory)
  String? _selectedSubCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _imagePath;
  bool _hasAttemptedSave = false;

  /// Guard: prevents double-pop from simultaneous gesture+overscroll events
  bool _popping = false;

  // Focus nodes for auto-navigation
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  // final FocusNode _notesFocus = FocusNode(); for now i just disable it  to test the user experience

  // Controllers for proper text field management
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  bool _didInit = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    // Initialize with existing transaction data if editing
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _selectedType = transaction.type;
      _amount = transaction.amount.abs().toString();
      _description = transaction.description;
      _notes = transaction.notes ?? '';
      _selectedAccountId = transaction.accountId;
      _selectedToAccountId = transaction.toAccountId;
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
      _imagePath = transaction.imagePath;

      // Set controller values
      _descriptionController.text = _description;
      _amountController.text = _amount;
      _notesController.text = _notes;
    } else {
      // Apply initialType if provided (from quick-add drawer)
      if (widget.initialType != null) {
        _selectedType = widget.initialType!;
      }
      // Pre-select the default account if provided
      if (widget.defaultAccountId != null) {
        _selectedAccountId = widget.defaultAccountId;
      }
    }

    // Auto-focus appropriate field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocus.requestFocus();

      if (widget.transaction != null) {
        _descriptionController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _descriptionController.text.length,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    // Resolve category for editing (needs context → controller)
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      final savedCat = context.read<TransactionController>().categories
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;
      if (savedCat != null && savedCat.isSubCategory) {
        _selectedParentCategoryId = savedCat.parentCategoryId;
        _selectedSubCategoryId = savedCat.id;
        _selectedCategoryId = savedCat.id;
      } else {
        _selectedParentCategoryId = savedCat?.id;
        _selectedSubCategoryId = null;
        _selectedCategoryId = savedCat?.id;
      }
    }
  }

  @override
  void dispose() {
    _descriptionFocus.dispose();
    _amountFocus.dispose();
    _categoryFocus.dispose();
    // _notesFocus.dispose(); //here also i am disabling it to test the user experience
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Closes the dialog exactly once, no matter how many gestures fire.
  void _closeDialog() {
    if (_popping || !mounted) return;
    _popping = true;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ── Swipe DOWN anywhere on the screen → close (Kora Launcher pattern) ──
      // The scroll view consumes the drag when NOT at top, so scrolling is safe.
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          _closeDialog();
        }
      },
      // Horizontal swipe anywhere to cycle transaction type
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _cycleType(-1);
        } else if (details.primaryVelocity! < 0) {
          _cycleType(1);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.transaction != null
                ? 'Edit Transaction'
                : (_selectedType == AppConstants.transactionTypeTransfer
                      ? 'Transfer Money'
                      : 'Add Transaction'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: _saveTransaction,
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Visual drag handle (decorative only — swipe works on entire screen)
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Always visible type selector at top
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildTypeSelector(),
              ),

              // Scrollable content — NotificationListener closes on overscroll
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // When at top of list and user pulls DOWN past -30px → close
                    if (notification.metrics.pixels <= -30) {
                      _closeDialog();
                      return true;
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Details Cards
                        _buildTransactionTitleCard(),
                        const SizedBox(height: 8),

                        _buildAmountCard(),
                        const SizedBox(height: 8),

                        // Transfer-specific UI
                        if (_selectedType ==
                            AppConstants.transactionTypeTransfer) ...[
                          _buildFromAccountCard(),
                          const SizedBox(height: 8),
                          _buildToAccountCard(),
                          const SizedBox(height: 8),
                        ] else ...[
                          _buildAccountCard(),
                          const SizedBox(height: 8),
                          _buildCategoryCard(),
                          const SizedBox(height: 8),
                          // Sub-category card — shown automatically when
                          // the selected parent has sub-categories
                          if (_selectedParentCategoryId != null &&
                              _txn
                                  .getSubCategories(_selectedParentCategoryId!)
                                  .isNotEmpty) ...
                          [
                            _buildSubCategoryCard(),
                            const SizedBox(height: 8),
                          ],
                        ],

                        _buildDateTimeCard(),
                        const SizedBox(height: 8),

                        _buildImageAttachmentCard(),
                        const SizedBox(height: 8),

                        _buildNotesCard(),
                        const SizedBox(height: 24),

                        // Update Transaction Button
                        _buildUpdateButton(),
                        const SizedBox(height: 24), // Extra space for keyboard
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return GestureDetector(
      onPanUpdate: (details) {
        // Detect horizontal swipe gestures
        if (details.delta.dx > 10) {
          // Swipe right - go to previous type
          _cycleType(-1);
        } else if (details.delta.dx < -10) {
          // Swipe left - go to next type
          _cycleType(1);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTypeChip('Income', Icons.trending_up, Colors.green),
            _buildTypeChip('Expense', Icons.trending_down, Colors.red),
            _buildTypeChip('Transfer', Icons.swap_horiz, Colors.blue),
          ],
        ),
      ),
    );
  }

  void _cycleType(int direction) {
    final types = [
      AppConstants.transactionTypeIncome,
      AppConstants.transactionTypeExpense,
      AppConstants.transactionTypeTransfer,
    ];
    final currentIndex = types.indexOf(_selectedType);

    int newIndex;
    if (direction > 0) {
      // Swipe left - go to next type
      newIndex = (currentIndex + 1) % types.length;
    } else {
      // Swipe right - go to previous type
      newIndex = (currentIndex - 1 + types.length) % types.length;
    }

    setState(() {
      _selectedType = types[newIndex];
      // Always reset category and toAccount when type changes (even during edit)
      _selectedCategoryId = null; // Reset category when type changes
      _selectedToAccountId = null; // Reset to account for transfers
    });
  }

  Widget _buildTypeChip(String label, IconData icon, Color color) {
    final isSelected = _selectedType == label.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = label.toLowerCase();
            // Always reset category and toAccount when type changes (even during edit)
            _selectedCategoryId = null; // Reset category when type changes
            _selectedToAccountId = null; // Reset to account for transfers
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTitleCard() {
    final hasError = _hasAttemptedSave && _description.trim().isEmpty;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasError
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: hasError
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: _descriptionFocus,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText:
                      _selectedType == AppConstants.transactionTypeTransfer
                      ? 'Transfer Description'
                      : 'Transaction Title',
                  border: InputBorder.none,
                  hintText:
                      _selectedType == AppConstants.transactionTypeTransfer
                      ? 'e.g., Moving money to savings'
                      : 'Enter transaction title',
                  errorText: hasError ? 'Required field' : null,
                ),
                onChanged: (value) => _description = value,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  _amountFocus.requestFocus();
                  // Auto-select all text in amount if editing
                  if (widget.transaction != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _amountController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _amountController.text.length,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final hasError = _hasAttemptedSave && _amount.trim().isEmpty;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasError
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons
                  .payments, // Icons.attach_money here you can change the icon for the amount feild
              color: hasError
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: _amountFocus,
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: InputBorder.none,
                  hintText: '0.00',
                  prefixText:
                      '${Formatters.getCurrencySymbol()} (${AppConstants.defaultCurrency})  ',
                  errorText: hasError ? 'Required field' : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _amount = value,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  // If account is pre-selected, go to category
                  if (widget.defaultAccountId != null) {
                    _showCategoryPicker();
                  } else {
                    // Otherwise, show account picker
                    if (_selectedType == AppConstants.transactionTypeTransfer) {
                      _showFromAccountPicker();
                    } else {
                      _showAccountPicker();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromAccountCard() {
    final selectedAccount = _acc.accounts
        .where((account) => account.id == _selectedAccountId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedAccountId == null;

    return GestureDetector(
      onTap: () => _showFromAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ??
                          'Select Source Account${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                    if (selectedAccount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAccount.type == AccountType.creditCard
                            ? '${Formatters.getCurrencySymbol()}${selectedAccount.balance.abs().toStringAsFixed(0)} ${selectedAccount.balance < 0 ? '(Credit)' : '(Debt)'}'
                            : '${Formatters.getCurrencySymbol()}${selectedAccount.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selectedAccount.balanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showFromAccountPicker(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToAccountCard() {
    final selectedAccount = _acc.accounts
        .where((account) => account.id == _selectedToAccountId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedToAccountId == null;

    return GestureDetector(
      onTap: () => _showToAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.account_balance, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ??
                          'Select Destination Account${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                    if (selectedAccount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAccount.type == AccountType.creditCard
                            ? '${Formatters.getCurrencySymbol()}${selectedAccount.balance.abs().toStringAsFixed(0)} ${selectedAccount.balance < 0 ? '(Credit)' : '(Debt)'}'
                            : '${Formatters.getCurrencySymbol()}${selectedAccount.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selectedAccount.balanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showToAccountPicker(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    final selectedAccount = _acc.accounts
        .where((account) => account.id == _selectedAccountId)
        .firstOrNull;
    final hasError = _hasAttemptedSave && _selectedAccountId == null;

    return GestureDetector(
      onTap: () => _showAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                selectedAccount?.icon ?? Icons.account_balance,
                color:
                    selectedAccount?.color ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ??
                          'Select Account${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                    if (selectedAccount != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAccount.type == AccountType.creditCard
                            ? '${Formatters.getCurrencySymbol()}${selectedAccount.balance.abs().toStringAsFixed(0)} ${selectedAccount.balance < 0 ? '(Credit)' : '(Debt)'}'
                            : '${Formatters.getCurrencySymbol()}${selectedAccount.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selectedAccount.balanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAccountPicker(),
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1 — parent category card
  Widget _buildCategoryCard() {
    final parentCat = _selectedParentCategoryId != null
        ? _txn.categories
            .where((c) => c.id == _selectedParentCategoryId)
            .firstOrNull
        : null;
    final hasError = _hasAttemptedSave && _selectedCategoryId == null;

    return GestureDetector(
      onTap: () => _showCategoryPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: hasError
              ? const BorderSide(color: Colors.red, width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                parentCat?.icon ?? Icons.category,
                color: parentCat?.color ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parentCat?.name ??
                          'Select Category${hasError ? " *" : ""}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hasError ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryPicker(),
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 2 — optional sub-category card (shown only when parent has subs)
  Widget _buildSubCategoryCard() {
    final selectedSub = _selectedSubCategoryId != null
        ? _txn.categories
            .where((c) => c.id == _selectedSubCategoryId)
            .firstOrNull
        : null;

    return GestureDetector(
      onTap: () => _showCategoryPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                selectedSub?.icon ?? Icons.subdirectory_arrow_right,
                color: selectedSub?.color ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sub-category',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedSub?.name ?? 'Optional — tap to select',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: selectedSub != null
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: selectedSub != null
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Clear sub-category button (only if one is selected)
              if (selectedSub != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubCategoryId = null;
                      _selectedCategoryId = _selectedParentCategoryId;
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Remove sub-category',
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Date Section with Swipe
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  } else if (details.primaryVelocity! < 0) {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _showDatePicker(),
                            child: Text(
                              Formatters.formatDate(_selectedDate),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Container(
              height: 32,
              width: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            // Time Section with Swipe
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    setState(() {
                      _selectedTime = TimeOfDay(
                        hour: (_selectedTime.hour - 1) % 24,
                        minute: _selectedTime.minute,
                      );
                    });
                  } else if (details.primaryVelocity! < 0) {
                    setState(() {
                      _selectedTime = TimeOfDay(
                        hour: (_selectedTime.hour + 1) % 24,
                        minute: _selectedTime.minute,
                      );
                    });
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _showTimePicker(),
                            child: Text(
                              _selectedTime.format(context),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                // focusNode: _notesFocus,
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: InputBorder.none,
                  hintText: 'Add notes...',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onChanged: (value) => _notes = value,
                onSubmitted: (_) => _saveTransaction(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet to choose between Camera and Gallery,
  /// handling the CAMERA permission request before opening the camera.
  Future<void> _pickImage() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Add Receipt Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ── Camera ─────────────────────────────────────
                    _imageSourceButton(
                      label: 'Camera',
                      icon: Icons.camera_alt_rounded,
                      color: AppConstants.primaryColor,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await _openCamera();
                      },
                    ),
                    // ── Gallery ────────────────────────────────────
                    _imageSourceButton(
                      label: 'Gallery',
                      icon: Icons.photo_library_rounded,
                      color: AppConstants.infoColor,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await _openGallery();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageSourceButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  /// Requests camera permission then opens the camera.
  Future<void> _openCamera() async {
    final shouldContinue = await PermissionDisclosureDialog.show(
      context: context,
      title: 'Camera Access Needed',
      reason: 'Kora uses the camera strictly to capture receipt photos to attach to your transactions. This data is stored locally on your device.',
      icon: Icons.camera_alt,
    );

    if (!shouldContinue || !mounted) return;

    final status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null && mounted) {
        setState(() => _imagePath = photo.path);
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Camera permission is permanently denied. Please enable it in Settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Denied but not permanently — show a quick message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Opens the gallery.
  Future<void> _openGallery() async {
    final shouldContinue = await PermissionDisclosureDialog.show(
      context: context,
      title: 'Gallery Access Needed',
      reason: 'Kora uses gallery access strictly to allow you to select existing receipt photos to attach to your transactions. This data is stored locally on your device.',
      icon: Icons.photo_library,
    );

    if (!shouldContinue || !mounted) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      setState(() => _imagePath = image.path);
    }
  }

  Widget _buildImageAttachmentCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Receipt / Attachment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (_imagePath != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _imagePath = null),
                    tooltip: 'Remove Image',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, size: 20),
                    onPressed: _pickImage,
                    tooltip: 'Add Image',
                  ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.zero,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(color: Colors.black87),
                          ),
                          InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              padding: const EdgeInsets.all(8),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _hasAttemptedSave = true;
          });

          final isValid =
              _amount.trim().isNotEmpty &&
              _description.trim().isNotEmpty &&
              _selectedAccountId != null &&
              (_selectedType != AppConstants.transactionTypeTransfer ||
                  _selectedToAccountId != null) &&
              (_selectedType == AppConstants.transactionTypeTransfer ||
                  _selectedCategoryId != null);

          if (isValid) {
            _saveTransaction();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(_selectedType),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(
          widget.transaction != null
              ? Icons.save
              : (_selectedType == AppConstants.transactionTypeTransfer
                    ? Icons.swap_horiz
                    : Icons.receipt_long),
        ),
        label: Text(
          widget.transaction != null
              ? 'Save Changes'
              : (_selectedType == AppConstants.transactionTypeTransfer
                    ? 'Complete Transfer'
                    : 'Add Transaction'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showFromAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Source Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _acc.accounts
                    .where((account) {
                      // For transfers, only show asset accounts as source
                      if (_selectedType ==
                          AppConstants.transactionTypeTransfer) {
                        return account.type.isAsset;
                      }
                      return true;
                    })
                    .map(
                      (account) => ListTile(
                        leading: Icon(account.icon, color: account.color),
                        title: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          account.type == AccountType.creditCard
                              ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
                              : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: account.balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedAccountId = account.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus next field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showToAccountPicker();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToAccountPicker() {
    final availableAccounts = _acc.accounts
        .where((account) => account.id != _selectedAccountId)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Destination Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: availableAccounts
                    .map(
                      (account) => ListTile(
                        leading: Icon(account.icon, color: account.color),
                        title: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          account.type == AccountType.creditCard
                              ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
                              : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: account.balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedToAccountId = account.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus notes field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // _notesFocus.requestFocus();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _acc.accounts
                    .map(
                      (account) => ListTile(
                        leading: Icon(account.icon, color: account.color),
                        title: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text(
                          account.type == AccountType.creditCard
                              ? '${Formatters.getCurrencySymbol()}${account.balance.abs().toStringAsFixed(0)} ${account.balance < 0 ? '(Credit)' : '(Debt)'}'
                              : '${Formatters.getCurrencySymbol()}${account.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: account.balanceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedAccountId = account.id;
                          });
                          Navigator.of(context).pop();
                          // Auto-focus next field after selection
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showCategoryPicker();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final topLevel = _txn.topLevelCategories.where((c) {
      if (_selectedType == AppConstants.transactionTypeIncome) {
        return c.type == AppConstants.categoryTypeIncome ||
            c.type == AppConstants.categoryTypeBoth;
      } else if (_selectedType == AppConstants.transactionTypeExpense) {
        return c.type == AppConstants.categoryTypeExpense ||
            c.type == AppConstants.categoryTypeBoth;
      }
      return true;
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: topLevel.map((category) {
                  final subs = _txn.getSubCategories(category.id).where((s) {
                    if (_selectedType == AppConstants.transactionTypeIncome) {
                      return s.type == AppConstants.categoryTypeIncome ||
                          s.type == AppConstants.categoryTypeBoth;
                    } else if (_selectedType == AppConstants.transactionTypeExpense) {
                      return s.type == AppConstants.categoryTypeExpense ||
                          s.type == AppConstants.categoryTypeBoth;
                    }
                    return true;
                  }).toList();

                  if (subs.isEmpty) {
                    return ListTile(
                      leading: Icon(category.icon, color: category.color),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedParentCategoryId = category.id;
                          _selectedSubCategoryId = null;
                          _selectedCategoryId = category.id;
                        });
                      },
                    );
                  }

                  // If it has sub-categories, use ExpansionTile
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent, // Remove line when expanded
                    ),
                    child: ExpansionTile(
                      leading: Icon(category.icon, color: category.color),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${subs.length} sub',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      childrenPadding: const EdgeInsets.only(left: 32),
                      children: [
                        // Option to just select the parent
                        ListTile(
                          leading: const Icon(Icons.check_circle_outline, size: 20),
                          title: Text('Select "${category.name}"'),
                          dense: true,
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedParentCategoryId = category.id;
                              _selectedSubCategoryId = null;
                              _selectedCategoryId = category.id;
                            });
                          },
                        ),
                        // List the actual sub-categories
                        ...subs.map((sub) => ListTile(
                              leading: Icon(sub.icon, color: sub.color, size: 20),
                              title: Text(sub.name),
                              dense: true,
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _selectedParentCategoryId = category.id;
                                  _selectedSubCategoryId = sub.id;
                                  _selectedCategoryId = sub.id;
                                });
                              },
                            )),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case AppConstants.transactionTypeIncome:
        return Colors.green;
      case AppConstants.transactionTypeExpense:
        return Colors.red;
      case AppConstants.transactionTypeTransfer:
        return Colors.blue; // Blue color for transfers (not disabled)
      default:
        return Colors.grey;
    }
  }

  void _saveTransaction() async {
    if (_amount.isEmpty || _selectedAccountId == null) {
      return;
    }

    if (_selectedType == AppConstants.transactionTypeTransfer &&
        _selectedToAccountId == null) {
      return;
    }

    if (_selectedType != AppConstants.transactionTypeTransfer &&
        _selectedCategoryId == null) {
      return;
    }

    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      return;
    }

    // Use sub-category if selected, otherwise parent category
    final finalCategoryId = _selectedCategoryId ?? 'transfer';

    Transaction transaction;
    if (widget.transaction != null) {
      transaction = Transaction(
        id: widget.transaction!.id,
        type: _selectedType,
        amount: amount,
        description: _description.isEmpty ? 'No description' : _description,
        categoryId: finalCategoryId,
        accountId: _selectedAccountId!,
        toAccountId: _selectedToAccountId,
        notes: _notes.isEmpty ? null : _notes,
        imagePath: _imagePath,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        createdAt: widget.transaction!.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      transaction = Transaction.create(
        type: _selectedType,
        amount: amount,
        description: _description.isEmpty ? 'No description' : _description,
        categoryId: finalCategoryId,
        accountId: _selectedAccountId!,
        toAccountId: _selectedToAccountId,
        notes: _notes.isEmpty ? null : _notes,
        imagePath: _imagePath,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
      );
    }

    bool success = false;
    if (widget.transaction != null) {
      // Update existing transaction
      success = await _txn.updateTransaction(
        widget.transaction!.id,
        transaction,
      );
    } else {
      // Add new transaction
      success = await _txn.addTransaction(transaction);
    }

    if (success) {
      Navigator.of(context).pop(true); // Return true to indicate success

      // Show success message only if no defaultAccountId (not from credit card screen)
      if (widget.defaultAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction != null
                  ? 'Transaction updated successfully!'
                  : (_selectedType == AppConstants.transactionTypeTransfer
                        ? 'Transfer completed successfully!'
                        : 'Transaction added successfully!'),
            ),
            backgroundColor: _getTypeColor(_selectedType),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _txn.error ?? 'Failed to save transaction',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }
  }
}
