import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/core/font_size_provider.dart';

class ScaledText extends StatelessWidget {
  const ScaledText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
        if (baseStyle == null) return Text(text);

        return Text(
          text,
          style: baseStyle.copyWith(
            fontSize:
                (baseStyle.fontSize ?? 14.0) * fontSizeProvider.scaleFactor,
            color: baseStyle.color,
            fontWeight: baseStyle.fontWeight,
            fontStyle: baseStyle.fontStyle,
            letterSpacing: baseStyle.letterSpacing,
            wordSpacing: baseStyle.wordSpacing,
            height: baseStyle.height,
            decoration: baseStyle.decoration,
            decorationColor: baseStyle.decorationColor,
            decorationStyle: baseStyle.decorationStyle,
            decorationThickness: baseStyle.decorationThickness,
            fontFamily: baseStyle.fontFamily,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
        );
      },
    );
  }
}
