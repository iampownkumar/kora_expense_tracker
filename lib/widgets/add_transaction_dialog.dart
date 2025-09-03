import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';
import 'package:kora_expense_tracker/models/transaction.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/providers/app_provider.dart';
import 'package:kora_expense_tracker/utils/formatters.dart';

class AddTransactionDialog extends StatefulWidget {
  final AppProvider appProvider;
  final Transaction? transaction; // For editing existing transactions
  final String? defaultAccountId; // Pre-select this account

  const AddTransactionDialog({
    super.key,
    required this.appProvider,
    this.transaction,
    this.defaultAccountId,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  String _selectedType = AppConstants.transactionTypeExpense;
  String _amount = '';
  String _description = '';
  String _notes = '';
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Focus nodes for auto-navigation
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();
  
  // Controllers for proper text field management
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

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
      _selectedCategoryId = transaction.categoryId;
      _selectedAccountId = transaction.accountId;
      _selectedToAccountId = transaction.toAccountId;
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
      
      // Set controller values
      _descriptionController.text = _description;
      _amountController.text = _amount;
      _notesController.text = _notes;
    } else if (widget.defaultAccountId != null) {
      // Pre-select the default account if provided
      _selectedAccountId = widget.defaultAccountId;
    }
    
    // Auto-focus appropriate field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always focus on description field first (transaction type/description)
      // This allows user to start typing the transaction description immediately
      _descriptionFocus.requestFocus();
      
      // Auto-select all text if editing
      if (widget.transaction != null) {
        _descriptionController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _descriptionController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _descriptionFocus.dispose();
    _amountFocus.dispose();
    _categoryFocus.dispose();
    _notesFocus.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe left/right anywhere in the app to change type
          if (details.primaryVelocity! > 0) {
            // Swipe right
            _cycleType(-1);
          } else if (details.primaryVelocity! < 0) {
            // Swipe left
            _cycleType(1);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Always visible type selector at top
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildTypeSelector(),
              ),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Details Cards
                      _buildTransactionTitleCard(),
                      const SizedBox(height: 16),

                      _buildAmountCard(),
                      const SizedBox(height: 16),

                      // Transfer-specific UI
                      if (_selectedType == AppConstants.transactionTypeTransfer) ...[
                        _buildFromAccountCard(),
                        const SizedBox(height: 16),
                        _buildToAccountCard(),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildAccountCard(),
                        const SizedBox(height: 16),
                        _buildCategoryCard(),
                        const SizedBox(height: 16),
                      ],

                      _buildDateTimeCard(),
                      const SizedBox(height: 16),

                      _buildNotesCard(),
                      const SizedBox(height: 24),

                      // Update Transaction Button
                      _buildUpdateButton(),
                      const SizedBox(height: 24), // Extra space for keyboard
                    ],
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
          color: Theme.of(context).colorScheme.surfaceVariant,
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
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                focusNode: _descriptionFocus,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: _selectedType == AppConstants.transactionTypeTransfer 
                      ? 'Transfer Description' 
                      : 'Transaction Title',
                  border: InputBorder.none,
                  hintText: _selectedType == AppConstants.transactionTypeTransfer 
                      ? 'e.g., Moving money to savings' 
                      : 'Enter transaction title',
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.payments, // Icons.attach_money here you can change the icon for the amount feild 
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  prefixText: '${Formatters.getCurrencySymbol()} (${AppConstants.defaultCurrency})  ',
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
    final selectedAccount = widget.appProvider.accounts
        .where((account) => account.id == _selectedAccountId)
        .firstOrNull;

    return GestureDetector(
      onTap: () => _showFromAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ?? 'Select Source Account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
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
    final selectedAccount = widget.appProvider.accounts
        .where((account) => account.id == _selectedToAccountId)
        .firstOrNull;

    return GestureDetector(
      onTap: () => _showToAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To Account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ?? 'Select Destination Account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
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
    final selectedAccount = widget.appProvider.accounts
        .where((account) => account.id == _selectedAccountId)
        .firstOrNull;

    return GestureDetector(
      onTap: () => _showAccountPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selectedAccount?.icon ?? Icons.account_balance,
                color: selectedAccount?.color ?? Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAccount?.name ?? 'Select Account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
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
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    final selectedCategory = widget.appProvider.categories
        .where((category) => category.id == _selectedCategoryId)
        .firstOrNull;

    return GestureDetector(
      onTap: () => _showCategoryPicker(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selectedCategory?.icon ?? Icons.category,
                color: selectedCategory?.color ?? Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedCategory?.name ?? 'Select Category',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryPicker(),
                icon: const Icon(Icons.add),
              ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date Row with Swipe
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swipe right - go to previous day
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                } else if (details.primaryVelocity! < 0) {
                  // Swipe left - go to next day
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Time Row with Swipe
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swipe right - go back 1 hour
                  setState(() {
                    _selectedTime = TimeOfDay(
                      hour: (_selectedTime.hour - 1) % 24,
                      minute: _selectedTime.minute,
                    );
                  });
                } else if (details.primaryVelocity! < 0) {
                  // Swipe left - go forward 1 hour
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.all(16),
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
                focusNode: _notesFocus,
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

  Widget _buildUpdateButton() {
    final isValid = _amount.isNotEmpty && 
                   _selectedAccountId != null &&
                   (_selectedType != AppConstants.transactionTypeTransfer || 
                    _selectedToAccountId != null) &&
                   (_selectedType == AppConstants.transactionTypeTransfer || 
                    _selectedCategoryId != null);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isValid ? _saveTransaction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(_selectedType),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(widget.transaction != null 
            ? Icons.save 
            : (_selectedType == AppConstants.transactionTypeTransfer 
                ? Icons.swap_horiz 
                : Icons.receipt_long)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Source Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.appProvider.accounts.where((account) {
                  // For transfers, only show asset accounts as source
                  if (_selectedType == AppConstants.transactionTypeTransfer) {
                    return account.type.isAsset;
                  }
                  return true;
                }).map((account) => ListTile(
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
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToAccountPicker() {
    final availableAccounts = widget.appProvider.accounts
        .where((account) => account.id != _selectedAccountId)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Destination Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: availableAccounts.map((account) => ListTile(
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
                      _notesFocus.requestFocus();
                    });
                  },
                )).toList(),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.appProvider.accounts.map((account) => ListTile(
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
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    // Filter categories based on transaction type
    final categories = widget.appProvider.categories.where((category) {
      if (_selectedType == AppConstants.transactionTypeIncome) {
        return category.type == AppConstants.categoryTypeIncome || 
               category.type == AppConstants.categoryTypeBoth;
      } else if (_selectedType == AppConstants.transactionTypeExpense) {
        return category.type == AppConstants.categoryTypeExpense || 
               category.type == AppConstants.categoryTypeBoth;
      }
      return true; // Show all for transfers
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: categories.map((category) => ListTile(
                  leading: Icon(category.icon, color: category.color),
                  title: Text(
                    category.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                    Navigator.of(context).pop();
                    // Auto-focus notes field after selection
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _notesFocus.requestFocus();
                      // Auto-select all text in notes if editing
                      if (widget.transaction != null) {
                        _notesController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _notesController.text.length,
                        );
                      }
                    });
                  },
                )).toList(),
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

    if (_selectedType == AppConstants.transactionTypeTransfer && _selectedToAccountId == null) {
      return;
    }

    if (_selectedType != AppConstants.transactionTypeTransfer && _selectedCategoryId == null) {
      return;
    }

    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      return;
    }

    final transaction = Transaction.create(
      type: _selectedType,
      amount: amount,
      description: _description.isEmpty ? 'No description' : _description,
      categoryId: _selectedCategoryId ?? 'transfer', // Default category for transfers
      accountId: _selectedAccountId!,
      toAccountId: _selectedToAccountId,
      notes: _notes.isEmpty ? null : _notes,
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
    );

    bool success = false;
    if (widget.transaction != null) {
      // Update existing transaction
      success = await widget.appProvider.updateTransaction(widget.transaction!.id, transaction);
    } else {
      // Add new transaction
      success = await widget.appProvider.addTransaction(transaction);
    }
    
    if (success) {
      Navigator.of(context).pop(true); // Return true to indicate success
      
      // Show success message only if no defaultAccountId (not from credit card screen)
      if (widget.defaultAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaction != null 
                ? 'Transaction updated successfully!' 
                : (_selectedType == AppConstants.transactionTypeTransfer 
                    ? 'Transfer completed successfully!' 
                    : 'Transaction added successfully!')),
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
          content: Text(widget.appProvider.error ?? 'Failed to save transaction'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 100,
          ),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }
  }
}
