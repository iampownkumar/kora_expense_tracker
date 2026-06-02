import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kora_expense_tracker/core/models/accounts/account.dart';
import 'package:kora_expense_tracker/core/models/accounts/account_type.dart';
import 'package:kora_expense_tracker/core/constants/app_constants.dart';
import 'package:kora_expense_tracker/screens/credit_cards/add_credit_card_screen.dart';

/// Clean single-page bottom sheet for adding/editing accounts.
/// No multi-step wizard — everything visible at once.
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
  final _nameFocus = FocusNode();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  AccountType _type = AccountType.savings;
  IconData _icon = Icons.savings;
  Color _color = const Color(0xFF1565C0); // deep blue
  bool _saving = false;

  // ── Palettes ────────────────────────────────────────────────────────────────
  static const _icons = [
    Icons.savings,
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.wallet,
    Icons.credit_card,
    Icons.money,
    Icons.payment,
    Icons.phone_android,
    Icons.business,
    Icons.home,
    Icons.school,
    Icons.work,
  ];

  static const _colors = [
    Color(0xFF1565C0), // deep blue
    Color(0xFF00897B), // teal
    Color(0xFF43A047), // green
    Color(0xFF7B1FA2), // purple
    Color(0xFFE53935), // red
    Color(0xFFF4511E), // deep orange
    Color(0xFFFB8C00), // orange
    Color(0xFF039BE5), // light blue
    Color(0xFF00ACC1), // cyan
    Color(0xFF5E35B1), // deep purple
    Color(0xFF3949AB), // indigo
    Color(0xFF8D6E63), // brown
  ];

  // ── Account type chips (Credit Card handled separately) ──────────────────────
  static const _types = [
    AccountType.savings,
    AccountType.wallet,
    AccountType.cash,
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.existingAccount;
    if (a != null) {
      _nameCtrl.text = a.name;
      _balanceCtrl.text = a.balance.toStringAsFixed(2);
      _noteCtrl.text = a.description ?? '';
      _type = a.type;
      _icon = a.icon;
      _color = a.color;
    } else {
      _balanceCtrl.text = '0';
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nameFocus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingAccount != null;

    return Padding(
      // push content above keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ──────────────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // ── Title row ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Animated account icon preview
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_icon, color: _color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Account' : 'New Account',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Divider(height: 1),

              // ── Scrollable form ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Account type chips ────────────────────────
                        _sectionLabel('Account Type'),
                        const SizedBox(height: 8),
                        _buildTypeChips(context),
                        const SizedBox(height: 20),

                        // ── 2. Name ──────────────────────────────────────
                        _sectionLabel('Account Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'e.g. HDFC Savings, Amazon Pay',
                            prefixIcon: const Icon(Icons.label_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length < 2) {
                              return 'Enter at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── 3. Balance ───────────────────────────────────
                        _sectionLabel('Opening Balance'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _balanceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\-?\d*\.?\d*')),
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Text(
                                AppConstants.defaultCurrencySymbol,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter an amount';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── 4. Note (optional) ───────────────────────────
                        _sectionLabel('Note  (optional)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _noteCtrl,
                          textInputAction: TextInputAction.done,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'e.g. Primary salary account',
                            prefixIcon:
                                const Icon(Icons.sticky_note_2_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── 5. Icon picker ───────────────────────────────
                        _sectionLabel('Icon'),
                        const SizedBox(height: 10),
                        _buildIconGrid(),
                        const SizedBox(height: 20),

                        // ── 6. Color picker ──────────────────────────────
                        _sectionLabel('Color'),
                        const SizedBox(height: 10),
                        _buildColorRow(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Save button ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Save Changes' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
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

  // ── Type chips ──────────────────────────────────────────────────────────────
  Widget _buildTypeChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Regular account types
        ..._types.map((t) {
          final selected = _type == t;
          return ChoiceChip(
            avatar: Icon(t.icon,
                size: 16,
                color: selected ? t.color : Theme.of(context).colorScheme.onSurfaceVariant),
            label: Text(t.displayName),
            selected: selected,
            selectedColor: t.color.withValues(alpha: 0.18),
            checkmarkColor: t.color,
            side: selected
                ? BorderSide(color: t.color, width: 1.5)
                : BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.4)),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? t.color : Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: (_) {
              setState(() {
                _type = t;
                _icon = t.icon;
                _color = t.color;
              });
            },
          );
        }),
        // Credit card chip → navigates away
        _creditCardChip(context),
      ],
    );
  }

  Widget _creditCardChip(BuildContext context) {
    return ActionChip(
      avatar: Icon(Icons.credit_card,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface),
      label: const Text('Credit Card'),
      labelStyle: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const AddCreditCardScreen()),
        );
      },
      tooltip: 'Opens credit card setup',
    );
  }

  // ── Icon grid ───────────────────────────────────────────────────────────────
  Widget _buildIconGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _icons.map((ico) {
        final sel = _icon == ico;
        return GestureDetector(
          onTap: () => setState(() => _icon = ico),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: sel
                  ? _color.withValues(alpha: 0.18)
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: sel
                  ? Border.all(color: _color, width: 2)
                  : null,
            ),
            child: Icon(ico,
                color: sel ? _color : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22),
          ),
        );
      }).toList(),
    );
  }

  // ── Color row ───────────────────────────────────────────────────────────────
  Widget _buildColorRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colors.map((c) {
        final sel = _color == c;
        return GestureDetector(
          onTap: () => setState(() => _color = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: sel
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: sel
                  ? [
                      BoxShadow(
                          color: c.withValues(alpha: 0.55),
                          blurRadius: 8,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
            child: sel
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final name = _nameCtrl.text.trim();
      final balance = double.parse(_balanceCtrl.text.trim());
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

      final account = widget.existingAccount?.copyWith(
            name: name,
            balance: balance,
            type: _type,
            icon: _icon,
            color: _color,
            description: note,
          ) ??
          Account.create(
            name: name,
            balance: balance,
            type: _type,
            icon: _icon,
            color: _color,
            description: note,
          );

      widget.onSave(account);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingAccount != null
                ? '✓ Account updated'
                : '✓ Account created'),
            behavior: SnackBarBehavior.floating,
            backgroundColor:
                Theme.of(context).colorScheme.inverseSurface,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
