import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'scaled_text.dart';

class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.onDelete,
    this.onCancel,
  });
  final String title;
  final String message;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;

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
                  UIConstants.deleteIconData,
                  color: UIConstants.errorColor,
                  size: 48,
                ),
                const SizedBox(height: UIConstants.spacingL),
                ScaledText(
                  title,
                  style: UIStyles.dialogTitleStyle.copyWith(
                    color: UIConstants.errorColor,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.cancelButtonBackground,
                        foregroundColor: UIConstants.cancelButtonText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingL,
                          vertical: UIConstants.spacingM,
                        ),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Abbrechen'),
                      onPressed:
                          onCancel ?? () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.deleteButtonBackground,
                        foregroundColor: UIConstants.deleteButtonText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingL,
                          vertical: UIConstants.spacingM,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Löschen'),
                      onPressed:
                          onDelete ?? () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
