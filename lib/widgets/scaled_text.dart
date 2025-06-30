import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/core/font_size_provider.dart';

class ScaledText extends StatelessWidget {
  const ScaledText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        final scaledStyle = style?.copyWith(
          fontSize: style?.fontSize != null
              ? style!.fontSize! * fontSizeProvider.scaleFactor
              : null,
        );
        return Text(
          text,
          style: scaledStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
