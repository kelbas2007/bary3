import 'package:flutter/material.dart';

/// Обертка для улучшения доступности виджетов
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool? button;
  final bool? header;
  final bool? image;
  final bool? textField;
  final bool? liveRegion;
  final VoidCallback? onTap;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.button,
    this.header,
    this.image,
    this.textField,
    this.liveRegion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      image: image,
      textField: textField,
      liveRegion: liveRegion,
      child: child,
    );

    if (onTap != null) {
      widget = GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }
}

/// Виджет для поддержки масштабирования шрифта
class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;

    return Text(
      text,
      style: style?.copyWith(
        fontSize: style!.fontSize != null
            ? textScaler.scale(style!.fontSize!)
            : null,
      ) ??
          defaultTextStyle.style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
