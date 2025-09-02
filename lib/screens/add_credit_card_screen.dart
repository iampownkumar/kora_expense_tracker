import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../models/account.dart';
import '../models/account_type.dart';
import '../utils/formatters.dart';

/// Add Credit Card Screen - User-friendly form for adding new credit cards
class AddCreditCardScreen extends StatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastFourDigitsController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _outstandingBalanceController = TextEditingController();
  final _interestRateController = TextEditingController(text: '18.0');
  final _minimumPaymentController = TextEditingController(text: '5.0');
  final _billingCycleDayController = TextEditingController(text: '15');
  final _gracePeriodController = TextEditingController(text: '21');
  final _notesController = TextEditingController();

  // Focus nodes for auto-focus functionality
  final _nameFocusNode = FocusNode();
  final _lastFourDigitsFocusNode = FocusNode();
  final _networkFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _bankFocusNode = FocusNode();
  final _creditLimitFocusNode = FocusNode();
  final _outstandingBalanceFocusNode = FocusNode();
  final _interestRateFocusNode = FocusNode();
  final _minimumPaymentFocusNode = FocusNode();
  final _billingCycleDayFocusNode = FocusNode();
  final _gracePeriodFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

  String _selectedNetwork = 'Visa';
  String _selectedType = 'Standard';
  String _selectedBank = 'Other';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.credit_card;
  DateTime? _selectedExpiryDate;
  bool _autoGenerateStatements = true;
  bool _isLoading = false;

  final List<String> _networks = ['Visa', 'Mastercard', 'Amex', 'Rupay', 'Discover'];
  final List<String> _types = ['Standard', 'Premium', 'Business', 'Student', 'Secured'];
  final List<String> _banks = [
    'HDFC Bank',
    'ICICI Bank',
    'SBI Bank',
    'Axis Bank',
    'Kotak Bank',
    'Yes Bank',
    'IndusInd Bank',
    'Federal Bank',
    'Other'
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];

  final List<IconData> _icons = [
    Icons.credit_card,
    Icons.account_balance,
    Icons.diamond,
    Icons.star,
    Icons.workspace_premium,
    Icons.business,
    Icons.school,
    Icons.flight,
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus on the first field when screen loads (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastFourDigitsController.dispose();
    _creditLimitController.dispose();
    _outstandingBalanceController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _billingCycleDayController.dispose();
    _gracePeriodController.dispose();
    _notesController.dispose();
    
    // Dispose focus nodes
    _nameFocusNode.dispose();
    _lastFourDigitsFocusNode.dispose();
    _networkFocusNode.dispose();
    _typeFocusNode.dispose();
    _bankFocusNode.dispose();
    _creditLimitFocusNode.dispose();
    _outstandingBalanceFocusNode.dispose();
    _interestRateFocusNode.dispose();
    _minimumPaymentFocusNode.dispose();
    _billingCycleDayFocusNode.dispose();
    _gracePeriodFocusNode.dispose();
    _notesFocusNode.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Credit Card'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCreditCard,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              _buildCardPreview(),
              const SizedBox(height: 32),
              
              // Basic Information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildLastFourDigitsField(),
              const SizedBox(height: 16),
              _buildExpiryDateField(),
              const SizedBox(height: 16),
              _buildNetworkDropdown(),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildBankDropdown(),
              const SizedBox(height: 24),
              
              // Financial Information
              _buildSectionHeader('Financial Information'),
              const SizedBox(height: 16),
              _buildCreditLimitField(),
              const SizedBox(height: 16),
              _buildOutstandingBalanceField(),
              const SizedBox(height: 16),
              _buildInterestRateField(),
              const SizedBox(height: 16),
              _buildMinimumPaymentField(),
              const SizedBox(height: 24),
              
              // Billing Information
              _buildSectionHeader('Billing Information'),
              const SizedBox(height: 16),
              _buildBillingCycleDayField(),
              const SizedBox(height: 16),
              _buildGracePeriodField(),
              const SizedBox(height: 16),
              _buildAutoGenerateStatementsSwitch(),
              const SizedBox(height: 24),
              
              // Appearance
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 16),
              _buildColorSelector(),
              const SizedBox(height: 16),
              _buildIconSelector(),
              const SizedBox(height: 24),
              
              // Notes
              _buildSectionHeader('Notes (Optional)'),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCreditCard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Credit Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _selectedIcon,
                  color: Colors.white,
                  size: 32,
                ),
                const Spacer(),
                Text(
                  _selectedNetwork,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _nameController.text.isEmpty ? 'Card Name' : _nameController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _lastFourDigitsController.text.isEmpty 
                  ? '•••• •••• •••• ••••'
                  : '•••• •••• •••• ${_lastFourDigitsController.text}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedExpiryDate != null 
                ? 'Expires ${_selectedExpiryDate!.month.toString().padLeft(2, '0')}/${_selectedExpiryDate!.year.toString().substring(2)}'
                : 'No expiry date',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to create consistent input decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    String? prefixText,
    String? suffixText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      prefixText: prefixText,
      suffixText: suffixText,
      helperText: helperText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Card Name',
        hintText: 'e.g., Chase Sapphire, Amex Gold',
        prefixIcon: Icons.credit_card,
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a card name';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _lastFourDigitsFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildLastFourDigitsField() {
    return TextFormField(
      controller: _lastFourDigitsController,
      focusNode: _lastFourDigitsFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Last 4 Digits',
        hintText: '1234',
        prefixIcon: Icons.numbers,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      maxLength: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the last 4 digits';
        }
        if (value.length != 4) {
          return 'Please enter exactly 4 digits';
        }
        return null;
      },
      onChanged: (value) => setState(() {}),
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _networkFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildExpiryDateField() {
    return InkWell(
      onTap: _selectExpiryDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Expiry Date (Optional)',
          helperText: 'Leave empty for privacy',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedExpiryDate != null 
            ? '${_selectedExpiryDate!.month.toString().padLeft(2, '0')}/${_selectedExpiryDate!.year}'
            : 'Not specified',
        ),
      ),
    );
  }

  Widget _buildNetworkDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedNetwork,
      focusNode: _networkFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Card Network',
        prefixIcon: Icons.network_check,
      ),
      items: _networks.map((network) => DropdownMenuItem(
        value: network,
        child: Text(network),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedNetwork = value!);
        _typeFocusNode.requestFocus();
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      focusNode: _typeFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Card Type',
        prefixIcon: Icons.category,
      ),
      items: _types.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedType = value!);
        _bankFocusNode.requestFocus();
      },
    );
  }

  Widget _buildBankDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBank,
      focusNode: _bankFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Bank',
        prefixIcon: Icons.account_balance,
      ),
      items: _banks.map((bank) => DropdownMenuItem(
        value: bank,
        child: Text(bank),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedBank = value!);
        _creditLimitFocusNode.requestFocus();
      },
    );
  }

  Widget _buildCreditLimitField() {
    return TextFormField(
      controller: _creditLimitController,
      focusNode: _creditLimitFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Credit Limit',
        hintText: '0.00',
        prefixText: Formatters.getCurrencySymbol(),
        prefixIcon: Icons.account_balance,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the credit limit';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _outstandingBalanceFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildOutstandingBalanceField() {
    return TextFormField(
      controller: _outstandingBalanceController,
      focusNode: _outstandingBalanceFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Current Outstanding Balance (Optional)',
        hintText: '0.00 - Leave empty if no balance',
        prefixText: Formatters.getCurrencySymbol(),
        prefixIcon: Icons.account_balance_wallet,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final amount = double.tryParse(value);
          if (amount == null || amount < 0) {
            return 'Please enter a valid amount';
          }
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _interestRateFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildInterestRateField() {
    return TextFormField(
      controller: _interestRateController,
      focusNode: _interestRateFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Interest Rate (APR)',
        hintText: '18.0',
        suffixText: '%',
        prefixIcon: Icons.percent,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the interest rate';
        }
        final rate = double.tryParse(value);
        if (rate == null || rate < 0 || rate > 100) {
          return 'Please enter a valid interest rate (0-100%)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _minimumPaymentFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildMinimumPaymentField() {
    return TextFormField(
      controller: _minimumPaymentController,
      focusNode: _minimumPaymentFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Minimum Payment Percentage',
        hintText: '5.0',
        suffixText: '%',
        prefixIcon: Icons.payment,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the minimum payment percentage';
        }
        final percentage = double.tryParse(value);
        if (percentage == null || percentage <= 0 || percentage > 100) {
          return 'Please enter a valid percentage (0-100%)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _billingCycleDayFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildBillingCycleDayField() {
    return TextFormField(
      controller: _billingCycleDayController,
      focusNode: _billingCycleDayFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Billing Cycle Day',
        hintText: '15',
        helperText: 'Day of month when billing cycle starts (1-31)',
        prefixIcon: Icons.calendar_today,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the billing cycle day';
        }
        final day = int.tryParse(value);
        if (day == null || day < 1 || day > 31) {
          return 'Please enter a valid day (1-31)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _gracePeriodFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildGracePeriodField() {
    return TextFormField(
      controller: _gracePeriodController,
      focusNode: _gracePeriodFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Grace Period',
        hintText: '21',
        suffixText: 'days',
        helperText: 'Days after due date before late fees',
        prefixIcon: Icons.schedule,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the grace period';
        }
        final days = int.tryParse(value);
        if (days == null || days < 1) {
          return 'Please enter a valid number of days';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          _notesFocusNode.requestFocus();
        }
      },
    );
  }

  Widget _buildAutoGenerateStatementsSwitch() {
    return SwitchListTile(
      title: const Text('Auto-generate Statements'),
      subtitle: const Text('Automatically generate billing statements'),
      value: _autoGenerateStatements,
      onChanged: (value) => setState(() => _autoGenerateStatements = value),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Color',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _colors.map((color) => GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
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
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Icon',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _icons.map((icon) => GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _selectedIcon == icon
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedIcon == icon
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
              child: Icon(
                icon,
                color: _selectedIcon == icon
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      focusNode: _notesFocusNode,
      decoration: _buildInputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Any additional notes about this card...',
        prefixIcon: Icons.note,
      ),
      textInputAction: TextInputAction.done,
      maxLines: 3,
    );
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365 * 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<void> _saveCreditCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final creditCard = CreditCard.create(
        name: _nameController.text.trim(),
        network: _selectedNetwork,
        type: _selectedType,
        lastFourDigits: _lastFourDigitsController.text.trim(),
        expiryDate: _selectedExpiryDate,
        creditLimit: double.parse(_creditLimitController.text),
        outstandingBalance: _outstandingBalanceController.text.trim().isEmpty 
          ? 0.0 
          : double.parse(_outstandingBalanceController.text),
        interestRate: double.parse(_interestRateController.text),
        minimumPaymentPercentage: double.parse(_minimumPaymentController.text),
        gracePeriodDays: int.parse(_gracePeriodController.text),
        billingCycleDay: int.parse(_billingCycleDayController.text),
        color: _selectedColor,
        icon: _selectedIcon,
        bankName: _selectedBank == 'Other' ? null : _selectedBank,
        autoGenerateStatements: _autoGenerateStatements,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final creditCardProvider = context.read<CreditCardProvider>();
      final appProvider = context.read<AppProvider>();
      
      // Add credit card
      final creditCardSuccess = await creditCardProvider.addCreditCard(creditCard);
      
      if (creditCardSuccess) {
        // Also create an Account object for the credit card with the same ID
        final account = Account(
          id: creditCard.id, // Use the same ID as the credit card
          name: _nameController.text.trim(),
          balance: creditCard.outstandingBalance, // Direct balance for liability
          type: AccountType.creditCard,
          icon: _selectedIcon,
          color: _selectedColor,
          description: 'Credit Card - ${_selectedNetwork} ${_lastFourDigitsController.text.trim()}',
          isActive: true,
          createdAt: creditCard.createdAt,
          updatedAt: creditCard.updatedAt,
        );
        
        // Add account to the app provider
        final accountSuccess = await appProvider.addAccount(account);
        
        if (accountSuccess) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Credit card added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Credit card added but failed to sync with accounts'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding credit card: ${creditCardProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding credit card: $e'),
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
}
