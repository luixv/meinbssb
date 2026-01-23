import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'scaled_text.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

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
    final scaleFactor =
        Provider.of<FontSizeProvider>(context, listen: false).scaleFactor;

    return Dialog(
      backgroundColor: UIConstants.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ScaledText(
                title,
                style: UIStyles.dialogTitleStyle.copyWith(
                  fontSize: UIStyles.dialogTitleStyle.fontSize! * scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            ScaledText(
              message,
              style: UIStyles.dialogContentStyle.copyWith(
                fontSize: UIStyles.dialogContentStyle.fontSize! * scaleFactor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingL),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed:
                        onCancel ?? () => Navigator.of(context).pop(false),
                    style: UIStyles.dialogCancelButtonStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: UIConstants.closeIcon),
                        UIConstants.horizontalSpacingS,
                        ScaledText(
                          'Abbrechen',
                          style: TextStyle(fontSize: 16.0 * scaleFactor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        onDelete ?? () => Navigator.of(context).pop(true),
                    style: UIStyles.dialogAcceptButtonStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: UIConstants.checkIcon),
                        UIConstants.horizontalSpacingS,
                        ScaledText(
                          'Löschen',
                          style: TextStyle(fontSize: 16.0 * scaleFactor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
