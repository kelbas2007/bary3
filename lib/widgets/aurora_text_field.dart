import 'package:flutter/material.dart';
import '../theme/aurora_theme.dart';

class AuroraTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final Color? iconColor;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuroraTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.iconColor,
    this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  State<AuroraTextField> createState() => _AuroraTextFieldState();
}

class _AuroraTextFieldState extends State<AuroraTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final iconColor = widget.iconColor ?? AuroraTheme.neonBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Анимированный лейбл
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: hasText || _isFocused
                ? iconColor
                : Colors.white54,
            fontSize: (hasText || _isFocused) ? 12 : 14,
            fontWeight: (hasText || _isFocused)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        
        // Поле ввода с градиентной рамкой при фокусе
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: _isFocused
                  ? LinearGradient(
                      colors: [
                        iconColor.withValues(alpha: 0.3),
                        iconColor.withValues(alpha: 0.1),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: iconColor,
                    width: 2,
                  ),
                ),
                prefixIcon: widget.icon != null
                    ? Icon(widget.icon, color: iconColor)
                    : null,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
