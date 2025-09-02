import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../models/bank_account.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';

/// Bank Accounts Management Screen
class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        actions: [
          IconButton(
            onPressed: () => _showAddBankAccountDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.bankAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.bankAccounts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => paymentProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paymentProvider.bankAccounts.length,
              itemBuilder: (context, index) {
                final bankAccount = paymentProvider.bankAccounts[index];
                return _buildBankAccountCard(bankAccount, paymentProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Bank Accounts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your bank accounts to make payments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBankAccountDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Bank Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccount bankAccount, PaymentProvider paymentProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bankAccount.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    bankAccount.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankAccount.bankName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bankAccount.accountTypeDisplayText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, bankAccount, paymentProvider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAccountInfo(
                    'Account Number',
                    bankAccount.maskedAccountNumber,
                    Icons.credit_card,
                  ),
                ),
                Expanded(
                  child: _buildAccountInfo(
                    'IFSC Code',
                    bankAccount.ifscCode,
                    Icons.code,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAccountInfo(
                    'Current Balance',
                    bankAccount.getFormattedBalance(),
                    Icons.account_balance_wallet,
                    AppConstants.availableColor,
                  ),
                ),
                Expanded(
                  child: _buildStatusChip(bankAccount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String label, String value, IconData icon, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BankAccount bankAccount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bankAccount.isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bankAccount.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (bankAccount.isVerified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showAddBankAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBankAccountDialog(),
    );
  }

  void _handleMenuAction(String action, BankAccount bankAccount, PaymentProvider paymentProvider) {
    switch (action) {
      case 'edit':
        _showEditBankAccountDialog(bankAccount);
        break;
      case 'delete':
        _showDeleteConfirmation(bankAccount, paymentProvider);
        break;
    }
  }

  void _showEditBankAccountDialog(BankAccount bankAccount) {
    showDialog(
      context: context,
      builder: (context) => AddBankAccountDialog(
        bankAccount: bankAccount,
      ),
    );
  }

  void _showDeleteConfirmation(BankAccount bankAccount, PaymentProvider paymentProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bank Account'),
        content: Text(
          'Are you sure you want to delete this bank account?\n\n'
          '${bankAccount.bankName} - ${bankAccount.maskedAccountNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await paymentProvider.deleteBankAccount(bankAccount.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank account deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(paymentProvider.error ?? 'Failed to delete bank account'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Add/Edit Bank Account Dialog
class AddBankAccountDialog extends StatefulWidget {
  final BankAccount? bankAccount;

  const AddBankAccountDialog({super.key, this.bankAccount});

  @override
  State<AddBankAccountDialog> createState() => _AddBankAccountDialogState();
}

class _AddBankAccountDialogState extends State<AddBankAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _balanceController = TextEditingController();

  String _selectedAccountType = 'savings';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.account_balance;
  bool _isActive = true;
  bool _isVerified = false;

  final List<String> _accountTypes = [
    'savings',
    'current',
    'salary',
    'nri',
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  final List<IconData> _availableIcons = [
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.savings,
    Icons.business,
    Icons.credit_card,
    Icons.payment,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bankAccount != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final bankAccount = widget.bankAccount!;
    _accountHolderController.text = bankAccount.accountHolderName;
    _bankNameController.text = bankAccount.bankName;
    _accountNumberController.text = bankAccount.accountNumber;
    _ifscController.text = bankAccount.ifscCode;
    _balanceController.text = bankAccount.currentBalance.toStringAsFixed(2);
    _selectedAccountType = bankAccount.accountType;
    _selectedColor = bankAccount.color;
    _selectedIcon = bankAccount.icon;
    _isActive = bankAccount.isActive;
    _isVerified = bankAccount.isVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bankAccount == null ? 'Add Bank Account' : 'Edit Bank Account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Account Holder Name
                  TextFormField(
                    controller: _accountHolderController,
                    decoration: InputDecoration(
                      labelText: 'Account Holder Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account holder name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Bank Name
                  TextFormField(
                    controller: _bankNameController,
                    decoration: InputDecoration(
                      labelText: 'Bank Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter bank name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Account Number
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: InputDecoration(
                      labelText: 'Account Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account number';
                      }
                      if (value.length < 9) {
                        return 'Account number must be at least 9 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // IFSC Code
                  TextFormField(
                    controller: _ifscController,
                    decoration: InputDecoration(
                      labelText: 'IFSC Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter IFSC code';
                      }
                      if (value.length != 11) {
                        return 'IFSC code must be 11 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Account Type
                  DropdownButtonFormField<String>(
                    value: _selectedAccountType,
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _accountTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getAccountTypeDisplayText(type)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Balance
                  TextFormField(
                    controller: _balanceController,
                    decoration: InputDecoration(
                      labelText: 'Current Balance',
                      prefixText: Formatters.getCurrencySymbol(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter current balance';
                      }
                      final balance = double.tryParse(value);
                      if (balance == null || balance < 0) {
                        return 'Please enter a valid balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Color Selection
                  Text(
                    'Account Color',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableColors.map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Icon Selection
                  Text(
                    'Account Icon',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableIcons.map((icon) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedIcon == icon
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Switches
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Active'),
                          subtitle: const Text('Account is active'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Verified'),
                          subtitle: const Text('Account is verified'),
                          value: _isVerified,
                          onChanged: (value) {
                            setState(() {
                              _isVerified = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveBankAccount,
                          child: Text(widget.bankAccount == null ? 'Add' : 'Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAccountTypeDisplayText(String type) {
    switch (type) {
      case 'savings':
        return 'Savings Account';
      case 'current':
        return 'Current Account';
      case 'salary':
        return 'Salary Account';
      case 'nri':
        return 'NRI Account';
      default:
        return type;
    }
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final paymentProvider = context.read<PaymentProvider>();
    
    try {
      final bankAccount = widget.bankAccount == null
          ? BankAccount.create(
              accountHolderName: _accountHolderController.text.trim(),
              bankName: _bankNameController.text.trim(),
              accountNumber: _accountNumberController.text.trim(),
              ifscCode: _ifscController.text.trim(),
              accountType: _selectedAccountType,
              currentBalance: double.parse(_balanceController.text),
              color: _selectedColor,
              icon: _selectedIcon,
              isActive: _isActive,
              isVerified: _isVerified,
            )
          : widget.bankAccount!.copyWith(
              accountHolderName: _accountHolderController.text.trim(),
              bankName: _bankNameController.text.trim(),
              accountNumber: _accountNumberController.text.trim(),
              ifscCode: _ifscController.text.trim(),
              accountType: _selectedAccountType,
              currentBalance: double.parse(_balanceController.text),
              color: _selectedColor,
              icon: _selectedIcon,
              isActive: _isActive,
              isVerified: _isVerified,
              updatedAt: DateTime.now(),
            );

      final success = widget.bankAccount == null
          ? await paymentProvider.addBankAccount(bankAccount)
          : await paymentProvider.updateBankAccount(bankAccount);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.bankAccount == null
                  ? 'Bank account added successfully'
                  : 'Bank account updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentProvider.error ?? 'Failed to save bank account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving bank account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
