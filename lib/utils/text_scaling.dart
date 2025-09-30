import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/font_size_provider.dart';
import '/constants/ui_constants.dart';

class ScaledTextStyle {
  static TextStyle scale(TextStyle baseStyle, BuildContext context) {
    final fontSizeProvider =
        Provider.of<FontSizeProvider>(context, listen: false);
    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize! * fontSizeProvider.scaleFactor,
    );
  }

  static TextStyle getAppBarTitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: 20.0,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.bold,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.titleFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.bold,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getSubtitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.subtitleFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.w500,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getButtonStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.buttonFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      context,
    );
  }

  static TextStyle getFormLabelStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getFormValueStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getFormValueBoldStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.bold,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getErrorStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.errorColor,
      ),
      context,
    );
  }

  static TextStyle getSuccessStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.successColor,
      ),
      context,
    );
  }

  static TextStyle getWarningStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.warningColor,
      ),
      context,
    );
  }

  static TextStyle getNewsStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.titleFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      context,
    );
  }

  static TextStyle getListItemTitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.w500,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getListItemSubtitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.mydarkGreyColor,
      ),
      context,
    );
  }

  static TextStyle getDialogTitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.titleFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.bold,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getDialogContentStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getDialogButtonTextStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.w500,
        color: UIConstants.whiteColor,
      ),
      context,
    );
  }

  static TextStyle getLinkStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.linkColor,
        decoration: TextDecoration.underline,
      ),
      context,
    );
  }

  static TextStyle getHeaderStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.headerFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        fontWeight: FontWeight.bold,
        color: UIConstants.defaultAppColor,
      ),
      context,
    );
  }

  static TextStyle getUserDataTextStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: UIConstants.bodyFontSize,
        fontFamily: UIConstants.defaultFontFamily,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getSectionTitleStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: UIConstants.textColor,
      ),
      context,
    );
  }

  static TextStyle getBodyTextStyle(BuildContext context) {
    return scale(
      const TextStyle(
        fontSize: 16.0,
        color: UIConstants.textColor,
      ),
      context,
    );
  }
}
