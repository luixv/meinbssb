import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

/// Reusable summary box for Bedürfnisantrag type (used in step 3 and step 5)
class AntragTypeSummaryBox extends StatelessWidget {
  const AntragTypeSummaryBox({super.key, this.wbkNeu, this.antragWbkNeu});
  final bool? wbkNeu;
  final bool? antragWbkNeu;

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
      listen: false,
    );
    // Prefer antragWbkNeu if provided, else fallback to wbkNeu
    final bool? effectiveWbkNeu = antragWbkNeu ?? wbkNeu;
    String message;
    if (effectiveWbkNeu == null) {
      message = 'WBK-Typ nicht angegeben.';
    } else if (effectiveWbkNeu == true) {
      message = 'Ich beantrage ein Bedürfnis für eine neue WBK';
    } else {
      message = 'Ich beantrage ein Bedürfnis für eine bestehende WBK';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.spacingM),
      decoration: BoxDecoration(
        color: UIConstants.cardColor,
        borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
        border: Border.all(color: UIConstants.defaultAppColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(
            'Bedürfnisantrag:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18 * fontSizeProvider.scaleFactor,
            ),
          ),
          const SizedBox(height: UIConstants.spacingM),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: ScaledText(
                message,
                style: TextStyle(fontSize: 16 * fontSizeProvider.scaleFactor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
