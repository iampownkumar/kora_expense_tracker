import 'package:flutter/material.dart';
import 'package:kora_expense_tracker/core/utils/formatters.dart';

/// Reusable widget to animate numeric financial values smoothly.
class AnimatedBalanceText extends StatefulWidget {
  final double value;
  final TextStyle style;
  final Duration duration;

  const AnimatedBalanceText({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedBalanceText> createState() => _AnimatedBalanceTextState();
}

class _AnimatedBalanceTextState extends State<AnimatedBalanceText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _oldValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedBalanceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          Formatters.formatCurrency(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}
