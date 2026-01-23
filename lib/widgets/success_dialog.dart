import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'scaled_text.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });
  final String title;
  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: UIConstants.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: UIConstants.spacingL),
                Icon(
                  UIConstants.successIcon,
                  color: UIConstants.successColor,
                  size: 48,
                ),
                const SizedBox(height: UIConstants.spacingL),
                ScaledText(
                  title,
                  style: UIStyles.dialogTitleStyle.copyWith(
                    color: UIConstants.successColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spacingM),
                ScaledText(
                  message,
                  style: UIStyles.dialogContentStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: UIConstants.spacingXL),
              ],
            ),
          ),
          Positioned(
            bottom: UIConstants.dialogFabTightBottom,
            right: UIConstants.dialogFabTightRight,
            child: FloatingActionButton(
              heroTag: 'fab_close_success_dialog',
              mini: true,
              backgroundColor: UIConstants.submitButtonBackground,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.close,
                color: UIConstants.buttonTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
