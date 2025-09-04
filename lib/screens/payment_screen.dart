import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/credit_card_provider.dart';
import '../models/credit_card.dart';
import '../models/account.dart';
import '../models/transaction.dart';
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
  
  final String _selectedPaymentMethod = 'transfer'; // Fixed to account transfer only
  Account? _selectedSourceAccount;
  bool _isProcessing = false;
  // bool _isScheduledPayment = false;
  // DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedAmount != null) {
      _amountController.text = widget.suggestedAmount!.toStringAsFixed(2);
    }
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
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
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
                  
                  // Payment Method (Fixed to Account Transfer)
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 24),
                  
                  // Source Account Selection (always required for account transfer)
                  _buildSourceAccountSection(appProvider),
                  
                  // Schedule Payment Section (hidden)
                  // _buildSchedulePaymentSection(),
                  
                  // Notes
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  
                  // Process Payment Button
                  _buildProcessPaymentButton(appProvider),
                  const SizedBox(height: 16),
                  
                  // Recent Payments
                  _buildRecentPayments(appProvider),
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
        // Financial wellness message
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '💡 Paying the full amount helps avoid interest charges and debt traps',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _setAmount(widget.creditCard.outstandingBalance),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Pay Full Amount'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _setAmount(widget.creditCard.minimumPaymentAmount),
                icon: const Icon(Icons.warning_amber, size: 18),
                label: const Text('Pay Minimum'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Account Transfer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.lock,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Payments are processed as account transfers from your selected account to the credit card.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceAccountSection(AppProvider appProvider) {
    // Get asset accounts (savings, wallet, cash, investment) that can be used for payments
    final availableAccounts = appProvider.accounts
        .where((account) => account.isAsset && account.balance > 0)
        .toList();
    
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
                'No Source Accounts Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please add accounts with available balance to make payments.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToAddAccount(),
                child: const Text('Add Account'),
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
          'Select Source Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Account>(
          value: _selectedSourceAccount,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            labelText: 'Choose Source Account',
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
            child: Text(
              '${account.name} • ${Formatters.formatCurrency(account.balance)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSourceAccount = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a source account';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget _buildSchedulePaymentSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Payment Schedule',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       
  //       // Schedule Toggle
  //       Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             children: [
  //               Row(
  //                 children: [
  //                   Icon(
  //                     Icons.schedule,
  //                     color: Theme.of(context).primaryColor,
  //                     size: 20,
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           'Schedule Payment',
  //                           style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         Text(
  //                           'Pay later instead of immediately',
  //                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Switch(
  //                     value: _isScheduledPayment,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _isScheduledPayment = value;
  //                         if (!value) {
  //                           _scheduledDate = null;
  //                         } else {
  //                           // Set default date to tomorrow
  //                           _scheduledDate = DateTime.now().add(const Duration(days: 1));
  //                         }
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               
  //               // Date Picker (shown when scheduled)
  //               if (_isScheduledPayment) ...[
  //                 const SizedBox(height: 16),
  //                 Container(
  //                   width: double.infinity,
  //                   padding: const EdgeInsets.all(16),
  //                   decoration: BoxDecoration(
  //                     color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
  //                     borderRadius: BorderRadius.circular(12),
  //                     border: Border.all(
  //                       color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
  //                     ),
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Scheduled Date',
  //                         style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                           fontWeight: FontWeight.bold,
  //                           color: Theme.of(context).primaryColor,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       InkWell(
  //                         onTap: _selectScheduledDate,
  //                         child: Container(
  //                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //                           decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.circular(8),
  //                             border: Border.all(color: Colors.grey.shade300),
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 Icons.calendar_today,
  //                                 color: Theme.of(context).primaryColor,
  //                                 size: 20,
  //                               ),
  //                               const SizedBox(width: 12),
  //                               Text(
  //                                 _scheduledDate != null 
  //                                     ? Formatters.formatDate(_scheduledDate!)
  //                                     : 'Select Date',
  //                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                                   color: _scheduledDate != null 
  //                                       ? Theme.of(context).colorScheme.onSurface
  //                                       : Colors.grey.shade600,
  //                                 ),
  //                               ),
  //                               const Spacer(),
  //                               Icon(
  //                                 Icons.arrow_drop_down,
  //                                 color: Colors.grey.shade600,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         'Payment will be processed automatically on the selected date.',
  //                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                           color: Theme.of(context).primaryColor,
  //                           fontStyle: FontStyle.italic,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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

  Widget _buildProcessPaymentButton(AppProvider appProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPayment(appProvider),
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

  Widget _buildRecentPayments(AppProvider appProvider) {
    // Get recent transfer transactions to this credit card
    final recentPayments = appProvider.transactions
        .where((transaction) => 
            transaction.isTransfer && 
            transaction.toAccountId == widget.creditCard.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (recentPayments.isNotEmpty)
              Text(
                '${recentPayments.length} payment${recentPayments.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentPayments.isEmpty)
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Payment History',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This will be your first payment to this credit card.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...recentPayments.take(10).map((transaction) => _buildPaymentItem(transaction)).toList(),
      ],
    );
  }

  Widget _buildPaymentItem(Transaction transaction) {
    final sourceAccount = context.read<AppProvider>().getAccountForTransaction(transaction.accountId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.green,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              Formatters.formatCurrency(transaction.amount.abs()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PAID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From ${sourceAccount?.name ?? 'Unknown Account'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  // Future<void> _selectScheduledDate() async {
  //   final now = DateTime.now();
  //   final firstDate = now.add(const Duration(days: 1)); // Can't schedule for today
  //   final lastDate = now.add(const Duration(days: 365)); // Max 1 year ahead
  //   
  //   final selectedDate = await showDatePicker(
  //     context: context,
  //     initialDate: _scheduledDate ?? firstDate,
  //     firstDate: firstDate,
  //     lastDate: lastDate,
  //     helpText: 'Select Payment Date',
  //     confirmText: 'Confirm',
  //     cancelText: 'Cancel',
  //   );
  //   
  //   if (selectedDate != null) {
  //     setState(() {
  //       _scheduledDate = selectedDate;
  //     });
  //   }
  // }



  Future<void> _processPayment(AppProvider appProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate source account selection for transfer payments
    if (_selectedPaymentMethod == 'transfer' && _selectedSourceAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate scheduled date if scheduling payment (disabled)
    // if (_isScheduledPayment && _scheduledDate == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select a scheduled date'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      
      // Find the Credit Card Payment category
      final creditCardPaymentCategory = appProvider.categories
          .firstWhere(
            (category) => category.name == 'Credit Card Payment',
            orElse: () => appProvider.categories.first, // Fallback to first category
          );

      // Handle immediate payment only
      await _processImmediatePayment(appProvider, amount, creditCardPaymentCategory);
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

  Future<void> _processImmediatePayment(AppProvider appProvider, double amount, category) async {
    // Create transfer transaction from source account to credit card
    final transaction = Transaction.create(
      type: 'transfer',
      amount: amount,
      description: 'Credit Card Payment - ${widget.creditCard.name}',
      categoryId: category.id,
      accountId: _selectedSourceAccount?.id ?? 'cash', // Use selected account or cash
      toAccountId: widget.creditCard.id, // Credit card as destination
      notes: _notesController.text.trim().isEmpty 
          ? 'Payment via Account Transfer'
          : '${_notesController.text.trim()} (via Account Transfer)',
    );

    // Add transaction using AppProvider
    final success = await appProvider.addTransaction(transaction);
    
    if (success) {
      // Refresh credit card provider to update payment data
      final creditCardProvider = Provider.of<CreditCardProvider>(context, listen: false);
      await creditCardProvider.refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Return success result to refresh parent screen
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.error ?? 'Payment processing failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _processScheduledPayment(AppProvider appProvider, double amount, category) async {
  //   // Create scheduled transaction (with future date)
  //   final transaction = Transaction.create(
  //     type: 'transfer',
  //     amount: amount,
  //     description: 'Scheduled Credit Card Payment - ${widget.creditCard.name}',
  //     categoryId: category.id,
  //     accountId: _selectedSourceAccount?.id ?? 'cash',
  //     toAccountId: widget.creditCard.id,
  //     date: _scheduledDate!, // Use scheduled date
  //     notes: _notesController.text.trim().isEmpty 
  //         ? 'Scheduled Payment via Account Transfer'
  //         : '${_notesController.text.trim()} (Scheduled Payment)',
  //   );

  //   // Add transaction using AppProvider
  //   final success = await appProvider.addTransaction(transaction);
  //   
  //   if (success) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Payment scheduled successfully for ${Formatters.formatDate(_scheduledDate!)}!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       Navigator.of(context).pop();
  //     }
  //   } else {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(appProvider.error ?? 'Payment scheduling failed'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  void _navigateToAddAccount() {
    // Navigate to accounts screen where user can add new accounts
    Navigator.of(context).pushNamed('/accounts');
  }
}
