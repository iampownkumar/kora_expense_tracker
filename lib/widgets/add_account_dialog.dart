import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora_expense_tracker/models/account.dart';
import 'package:kora_expense_tracker/models/account_type.dart';
import 'package:kora_expense_tracker/constants/app_constants.dart';

/// A user-friendly dialog for adding new accounts with auto-focus and progressive disclosure
class AddAccountDialog extends StatefulWidget {
  final Account? existingAccount;
  final Function(Account) onSave;

  const AddAccountDialog({
    super.key,
    this.existingAccount,
    required this.onSave,
  });

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  AccountType _selectedType = AccountType.savings;
  IconData _selectedIcon = Icons.account_balance;
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  int _currentStep = 0;
  
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _setupAutoFocus();
  }

  void _initializeFields() {
    if (widget.existingAccount != null) {
      final account = widget.existingAccount!;
      _nameController.text = account.name;
      _balanceController.text = account.balance.toString();
      _descriptionController.text = account.description ?? '';
      _selectedType = account.type;
      _selectedIcon = account.icon;
      _selectedColor = account.color;
    } else {
      _balanceController.text = '';
    }
  }

  void _setupAutoFocus() {
    // Auto-focus the first field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStep == 0) {
        // Focus on the first account type option
        _focusNodes[0].requestFocus();
      } else if (_currentStep == 1) {
        // Focus on the account name field and auto-select text if editing
        _focusNodes[0].requestFocus();
        if (widget.existingAccount != null) {
          _nameController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _nameController.text.length,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingAccount != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.borderRadius),
                  topRight: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Edit Account' : 'Add New Account',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Progress indicator
            if (!isEditing) _buildProgressIndicator(),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildAccountTypeStep(),
                      if (_currentStep == 1) _buildAccountDetailsStep(),
                      if (_currentStep == 2) _buildAccountCustomizationStep(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : theme.colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAccountTypeStep() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Account Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the type of account you want to add',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Account type options
        ...AccountType.values.map((type) => _buildAccountTypeOption(type)),
      ],
    );
  }

  Widget _buildAccountTypeOption(AccountType type) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? type.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedIcon = type.icon;
            _selectedColor = type.color;
          });
          // Auto-proceed to next step after selection
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_validateCurrentStep()) {
              _nextStep();
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type.icon,
                  color: type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getAccountTypeDescription(type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: type.color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetailsStep() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the basic information for your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Account name
        TextFormField(
          controller: _nameController,
          focusNode: _focusNodes[0],
          decoration: InputDecoration(
            labelText: 'Account Name',
            hintText: 'e.g., HDFC Savings, Amazon Pay',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            // Auto-focus to balance field
            _focusNodes[1].requestFocus();
            // Auto-select balance text if editing
            if (widget.existingAccount != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _balanceController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _balanceController.text.length,
                );
              });
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an account name';
            }
            if (value.trim().length < 2) {
              return 'Account name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Initial balance
        TextFormField(
          controller: _balanceController,
          focusNode: _focusNodes[1],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            // Auto-focus to description field
            _focusNodes[2].requestFocus();
            // Auto-select description text if editing
            if (widget.existingAccount != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _descriptionController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _descriptionController.text.length,
                );
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Initial Balance',
            hintText: '0.00',
            prefixIcon: const Icon(Icons.account_balance_wallet),
            prefixText: AppConstants.defaultCurrencySymbol,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an initial balance';
            }
            final balance = double.tryParse(value);
            if (balance == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Description (optional)
        TextFormField(
          controller: _descriptionController,
          focusNode: _focusNodes[2],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            // Auto-proceed to next step (Icon & Color)
            if (_validateCurrentStep()) {
              _nextStep();
            }
          },
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Add a note about this account',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildAccountCustomizationStep() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Appearance',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose an icon and color for your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        
        // Icon selection
        Text(
          'Icon',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAvailableIcons().map((icon) => _buildIconOption(icon)).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Color selection
        Text(
          'Color',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getAvailableColors().map((color) => _buildColorOption(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildIconOption(IconData icon) {
    final isSelected = _selectedIcon == icon;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? _selectedColor : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final isEditing = widget.existingAccount != null;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.borderRadius),
          bottomRight: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      child: Row(
        children: [
          if (!isEditing && _currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (!isEditing && _currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Save' : (_currentStep == 2 ? 'Create Account' : 'Next')),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        // Auto-focus next field with smooth transition
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentStep == 1) {
            // Step 1: Account Details - focus on name field
            _focusNodes[0].requestFocus();
            // Auto-select text if editing
            if (widget.existingAccount != null) {
              _nameController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _nameController.text.length,
              );
            }
          } else if (_currentStep == 2) {
            // Step 2: Icon & Color - no focus needed
            // This step doesn't have text fields
          }
        });
      }
    } else {
      _saveAccount();
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 1) {
      return _formKey.currentState?.validate() ?? false;
    }
    return true;
  }

  Future<void> _saveAccount() async {
    if (!_validateCurrentStep()) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('AddAccountDialog: Creating account with name: ${_nameController.text.trim()}');
      print('AddAccountDialog: Account type: $_selectedType');
      print('AddAccountDialog: Account icon: $_selectedIcon');
      print('AddAccountDialog: Account color: $_selectedColor');
      
      final account = widget.existingAccount?.copyWith(
        name: _nameController.text.trim(),
        balance: double.parse(_balanceController.text),
        type: _selectedType,
        icon: _selectedIcon,
        color: _selectedColor,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      ) ?? Account.create(
        name: _nameController.text.trim(),
        balance: double.parse(_balanceController.text),
        type: _selectedType,
        icon: _selectedIcon,
        color: _selectedColor,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );
      
      print('AddAccountDialog: Account created successfully: ${account.id}');
      print('AddAccountDialog: Calling onSave callback');
      
      widget.onSave(account);
      
      print('AddAccountDialog: onSave callback completed');
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAccount != null 
                  ? 'Account updated successfully!' 
                  : 'Account created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('AddAccountDialog: Error creating account: $e');
      print('AddAccountDialog: Error stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getAccountTypeDescription(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 'Bank savings account for your money';
      case AccountType.wallet:
        return 'Digital wallet like Paytm, PhonePe';
      case AccountType.creditCard:
        return 'Credit card for purchases';
      case AccountType.cash:
        return 'Physical cash in hand';
      case AccountType.investment:
        return 'Investment accounts and funds';
      case AccountType.loan:
        return 'Loans and debts to pay';
    }
  }

  List<IconData> _getAvailableIcons() {
    return [
      Icons.account_balance,
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.money,
      Icons.savings,
      Icons.payment,
      Icons.account_circle,
      Icons.wallet,
      Icons.business,
      Icons.home,
      Icons.school,
      Icons.work,
    ];
  }

  List<Color> _getAvailableColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
    ];
  }
}
