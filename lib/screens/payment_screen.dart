import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../providers/credit_card_provider.dart';
import '../models/credit_card.dart';
import '../models/payment.dart';
import '../models/bank_account.dart';
import '../utils/formatters.dart';
import '../constants/app_constants.dart';

/// Payment Screen for making credit card payments
class PaymentScreen extends StatefulWidget {
  final CreditCard creditCard;
  final double? suggestedAmount;

  const PaymentScreen({
    super.key,
    required this.creditCard,
    this.suggestedAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'bank_transfer';
  BankAccount? _selectedBankAccount;
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'bank_transfer',
    'debit_card',
    'upi',
    'net_banking',
    'wallet',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.suggestedAmount != null) {
      _amountController.text = widget.suggestedAmount!.toStringAsFixed(2);
    }
    
    // Initialize payment provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay ${widget.creditCard.name}'),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading && paymentProvider.bankAccounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credit Card Info
                  _buildCreditCardInfo(),
                  const SizedBox(height: 24),
                  
                  // Payment Amount
                  _buildAmountSection(),
                  const SizedBox(height: 24),
                  
                  // Payment Method
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 24),
                  
                  // Bank Account Selection (if applicable)
                  if (_selectedPaymentMethod == 'bank_transfer' || _selectedPaymentMethod == 'net_banking')
                    _buildBankAccountSection(paymentProvider),
                  
                  // Notes
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  
                  // Process Payment Button
                  _buildProcessPaymentButton(paymentProvider),
                  const SizedBox(height: 16),
                  
                  // Recent Payments
                  _buildRecentPayments(paymentProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreditCardInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.creditCard.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.creditCard.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.creditCard.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.creditCard.maskedCardNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    widget.creditCard.balanceLabel,
                    widget.creditCard.getFormattedUserBalance(),
                    widget.creditCard.userBalanceColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Available Credit',
                    widget.creditCard.getFormattedAvailableCredit(),
                    AppConstants.availableColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: '0.00',
            prefixText: Formatters.getCurrencySymbol(),
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
            prefixIcon: const Icon(Icons.payment),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter payment amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount > widget.creditCard.outstandingBalance) {
              return 'Amount cannot exceed outstanding balance';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _setAmount(widget.creditCard.outstandingBalance),
                child: const Text('Pay Full'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _setAmount(widget.creditCard.minimumPaymentAmount),
                child: const Text('Pay Minimum'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: InputDecoration(
            labelText: 'Select Payment Method',
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
            prefixIcon: const Icon(Icons.payment),
          ),
          items: _paymentMethods.map((method) => DropdownMenuItem(
            value: method,
            child: Text(_getPaymentMethodDisplayText(method)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
              _selectedBankAccount = null; // Reset bank account selection
            });
          },
        ),
      ],
    );
  }

  Widget _buildBankAccountSection(PaymentProvider paymentProvider) {
    final availableAccounts = paymentProvider.verifiedBankAccounts;
    
    if (availableAccounts.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No Bank Accounts Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please add and verify a bank account to make payments.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToAddBankAccount(),
                child: const Text('Add Bank Account'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Bank Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<BankAccount>(
          value: _selectedBankAccount,
          decoration: InputDecoration(
            labelText: 'Choose Bank Account',
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
            prefixIcon: const Icon(Icons.account_balance),
          ),
          items: availableAccounts.map((account) => DropdownMenuItem(
            value: account,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(account.displayName),
                Text(
                  '${account.maskedAccountNumber} • ${account.getFormattedBalance()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBankAccount = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a bank account';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Payment Notes',
            hintText: 'Add any notes about this payment...',
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
            prefixIcon: const Icon(Icons.note),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildProcessPaymentButton(PaymentProvider paymentProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPayment(paymentProvider),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Process Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildRecentPayments(PaymentProvider paymentProvider) {
    final recentPayments = paymentProvider.getPaymentsForCard(widget.creditCard.id)
        .take(5)
        .toList();

    if (recentPayments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recentPayments.map((payment) => _buildPaymentItem(payment)),
      ],
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: payment.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.payment,
            color: payment.statusColor,
            size: 20,
          ),
        ),
        title: Text(payment.getFormattedAmount()),
        subtitle: Text(
          '${payment.paymentMethodDisplayText} • ${Formatters.formatDate(payment.paymentDate)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: payment.statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            payment.statusDisplayText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  String _getPaymentMethodDisplayText(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'debit_card':
        return 'Debit Card';
      case 'upi':
        return 'UPI';
      case 'net_banking':
        return 'Net Banking';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return method;
    }
  }

  Future<void> _processPayment(PaymentProvider paymentProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate bank account selection for applicable payment methods
    if ((_selectedPaymentMethod == 'bank_transfer' || _selectedPaymentMethod == 'net_banking') &&
        _selectedBankAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      
      // Create payment
      final payment = Payment.create(
        creditCardId: widget.creditCard.id,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        bankAccountId: _selectedBankAccount?.id,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Add payment
      final success = await paymentProvider.addPayment(payment);
      
      if (success) {
        // Process payment
        final processSuccess = await paymentProvider.processPayment(payment);
        
        if (processSuccess) {
          // Update credit card balance
          final creditCardProvider = context.read<CreditCardProvider>();
          await creditCardProvider.updateCreditCardBalance(
            widget.creditCard.id,
            widget.creditCard.outstandingBalance - amount,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment processed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(paymentProvider.error ?? 'Payment processing failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentProvider.error ?? 'Failed to create payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _navigateToAddBankAccount() {
    // TODO: Navigate to add bank account screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Bank Account feature coming soon!'),
      ),
    );
  }
}
