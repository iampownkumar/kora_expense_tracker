import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kora_expense_tracker/features/transactions/transaction_controller.dart';
import '../../core/models/credit_cards/credit_card.dart';
import '../../core/models/transactions/transaction.dart';
import '../../core/utils/formatters.dart';

/// Payment History Screen for viewing all payments made to a credit card
class PaymentHistoryScreen extends StatelessWidget {
  final CreditCard creditCard;

  const PaymentHistoryScreen({
    super.key,
    required this.creditCard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History - ${creditCard.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionController>(
        builder: (context, txnCtrl, child) {
          // Get all payment transactions for this credit card
          final paymentTransactions = txnCtrl.transactions
              .where((transaction) => 
                  transaction.type == 'expense' && 
                  transaction.toAccountId == creditCard.id)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

          if (paymentTransactions.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Summary Card
              _buildSummaryCard(context, paymentTransactions),
              
              // Payment List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: paymentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = paymentTransactions[index];
                    return _buildPaymentCard(context, transaction);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This will be your first payment to this credit card.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<Transaction> payments) {
    final totalPaid = payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final paymentCount = payments.length;
    final lastPayment = payments.isNotEmpty ? payments.first : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Paid',
                  Formatters.formatCurrency(totalPaid),
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Payments Made',
                  paymentCount.toString(),
                  Icons.payment,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          if (lastPayment != null) ...[
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              'Last Payment',
              '${Formatters.formatCurrency(lastPayment.amount)} on ${Formatters.formatDate(lastPayment.date)}',
              Icons.schedule,
              Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment to ${creditCard.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Formatters.formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Image thumbnail
              if (transaction.imagePath != null && transaction.imagePath!.isNotEmpty) ...[
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
                                File(transaction.imagePath!),
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
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(transaction.imagePath!),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                Formatters.formatCurrency(transaction.amount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
