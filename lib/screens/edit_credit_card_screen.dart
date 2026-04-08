import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/app_provider.dart';
import '../models/credit_card.dart';
import '../utils/formatters.dart';

/// Edit Credit Card Screen - User-friendly credit card editing
class EditCreditCardScreen extends StatefulWidget {
  final CreditCard creditCard;

  const EditCreditCardScreen({
    super.key,
    required this.creditCard,
  });

  @override
  State<EditCreditCardScreen> createState() => _EditCreditCardScreenState();
}

class _EditCreditCardScreenState extends State<EditCreditCardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _creditLimitController;
  late TextEditingController _interestRateController;
  late TextEditingController _gracePeriodController;
  late TextEditingController _minimumPaymentController;
  
  late int _billingCycleDay;
  late DateTime? _nextBillingDate;
  late DateTime? _nextDueDate;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.creditCard.name);
    _creditLimitController = TextEditingController(text: widget.creditCard.creditLimit.toString());
    _interestRateController = TextEditingController(text: widget.creditCard.interestRate.toString());
    _gracePeriodController = TextEditingController(text: widget.creditCard.gracePeriodDays.toString());
    _minimumPaymentController = TextEditingController(text: widget.creditCard.minimumPaymentPercentage.toString());
    
    _billingCycleDay = widget.creditCard.billingCycleDay;
    _nextBillingDate = widget.creditCard.nextBillingDate;
    _nextDueDate = widget.creditCard.nextDueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    _gracePeriodController.dispose();
    _minimumPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Credit Card'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Information Section
            _buildSection(
              'Card Information',
              Icons.credit_card,
              [
                _buildTextField(
                  'Card Name',
                  _nameController,
                  Icons.badge,
                  'Enter card name (e.g., Chase Sapphire)',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Credit Limit',
                  _creditLimitController,
                  Icons.account_balance,
                  'Enter credit limit amount',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Billing Information Section
            _buildSection(
              'Billing Information',
              Icons.calendar_today,
              [
                _buildBillingCycleSelector(),
                const SizedBox(height: 16),
                _buildDateSelector(
                  'Next Billing Date',
                  _nextBillingDate,
                  Icons.receipt_long,
                  (date) => setState(() {
                    _nextBillingDate = date;
                    _updateDueDate();
                  }),
                ),
                const SizedBox(height: 16),
                _buildDateSelector(
                  'Next Due Date',
                  _nextDueDate,
                  Icons.payment,
                  (date) => setState(() => _nextDueDate = date),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Terms Section
            _buildSection(
              'Payment Terms',
              Icons.payment,
              [
                _buildTextField(
                  'Interest Rate (%)',
                  _interestRateController,
                  Icons.percent,
                  'Enter annual interest rate',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Grace Period (Days)',
                  _gracePeriodController,
                  Icons.schedule,
                  'Enter grace period in days',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Minimum Payment (%)',
                  _minimumPaymentController,
                  Icons.payment,
                  'Enter minimum payment percentage',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statement Period Change Warning
            _buildStatementPeriodWarning(),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Saving...'),
                        ],
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingCycleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Cycle Day',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: DropdownButton<int>(
            value: _billingCycleDay,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: List.generate(31, (index) => index + 1)
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text('$day${_getDaySuffix(day)} of each month'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _billingCycleDay = value;
                  _updateBillingDates();
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your credit card statement will be generated on the $_billingCycleDay${_getDaySuffix(_billingCycleDay)} of each month.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    IconData icon,
    Function(DateTime?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(date, onChanged),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  date != null ? Formatters.formatDate(date) : 'Select date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: date != null 
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatementPeriodWarning() {
    final billingChanged = _billingCycleDay != widget.creditCard.billingCycleDay;
    
    if (!billingChanged) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Billing Cycle Changed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Changing the billing cycle will affect your current statement period. The new cycle will start from the next billing date.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  void _updateBillingDates() {
    final now = DateTime.now();
    
    // Calculate next billing date
    DateTime nextBilling;
    if (now.day < _billingCycleDay) {
      nextBilling = DateTime(now.year, now.month, _billingCycleDay);
    } else {
      nextBilling = DateTime(now.year, now.month + 1, _billingCycleDay);
      if (nextBilling.month > 12) {
        nextBilling = DateTime(now.year + 1, 1, _billingCycleDay);
      }
    }
    
    _nextBillingDate = nextBilling;
    _updateDueDate();
  }

  void _updateDueDate() {
    if (_nextBillingDate != null) {
      final gracePeriod = int.tryParse(_gracePeriodController.text) ?? 21;
      _nextDueDate = _nextBillingDate!.add(Duration(days: gracePeriod));
    }
  }

  Future<void> _selectDate(DateTime? currentDate, Function(DateTime?) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      onChanged(date);
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a card name');
      return;
    }

    final creditLimit = double.tryParse(_creditLimitController.text);
    if (creditLimit == null || creditLimit <= 0) {
      _showError('Please enter a valid credit limit');
      return;
    }

    final interestRate = double.tryParse(_interestRateController.text);
    if (interestRate == null || interestRate < 0) {
      _showError('Please enter a valid interest rate');
      return;
    }

    final gracePeriod = int.tryParse(_gracePeriodController.text);
    if (gracePeriod == null || gracePeriod < 0) {
      _showError('Please enter a valid grace period');
      return;
    }

    final minimumPayment = double.tryParse(_minimumPaymentController.text);
    if (minimumPayment == null || minimumPayment < 0 || minimumPayment > 100) {
      _showError('Please enter a valid minimum payment percentage (0-100)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update credit card
      final updatedCard = widget.creditCard.copyWith(
        name: _nameController.text.trim(),
        creditLimit: creditLimit,
        interestRate: interestRate,
        gracePeriodDays: gracePeriod,
        minimumPaymentPercentage: minimumPayment,
        billingCycleDay: _billingCycleDay,
        nextBillingDate: _nextBillingDate,
        nextDueDate: _nextDueDate,
        availableCredit: creditLimit - widget.creditCard.outstandingBalance,
      );

      // Update in CreditCardProvider
      final creditCardProvider = context.read<CreditCardProvider>();
      final success = await creditCardProvider.updateCreditCard(updatedCard);

      if (success && mounted) {
        // Also update in AppProvider if it exists as an account
        final appProvider = context.read<AppProvider>();
        final account = appProvider.accounts.where(
          (acc) => acc.id == widget.creditCard.id,
        ).firstOrNull;

        if (account != null) {
          final updatedAccount = account.copyWith(
            name: _nameController.text.trim(),
            balance: -widget.creditCard.outstandingBalance,
          );
          await appProvider.updateAccount(updatedAccount);
        }

        if (mounted) {
          Navigator.of(context).pop(updatedCard);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credit card updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        _showError('Failed to update credit card');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error updating credit card: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
