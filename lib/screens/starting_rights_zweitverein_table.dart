import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/disziplin_data.dart';

class ZweitvereinTable extends StatelessWidget {
  const ZweitvereinTable({
    super.key,
    required this.seasonInt,
    required this.vereinName,
    required this.firstColumns,
    required this.secondColumns,
    required this.pivot,
    required this.disciplines,
    required this.onDelete,
    required this.onAdd,
  });
  final int seasonInt;
  final String vereinName;
  final Map<String, int?> firstColumns;
  final Map<String, int?> secondColumns;
  final Map<String, int?> pivot;
  final List<Disziplin> disciplines;
  final void Function(String key) onDelete;
  final void Function(Disziplin selected) onAdd;

  @override
  Widget build(BuildContext context) {
    // Define a consistent padding for all table cell content
    const EdgeInsets cellContentPadding = EdgeInsets.symmetric(
      vertical: UIConstants.spacingXXS,
      horizontal: UIConstants.spacingXXS,
    );

    return ExpansionTile(
      initiallyExpanded: true,
      title: Row(
        children: [
          ScaledText(
            '• ',
            style: UIStyles.subtitleStyle.copyWith(
              fontSize: (UIStyles.subtitleStyle.fontSize! * 1.5),
              height: UIConstants.spacingXXS,
            ),
          ),
          // FIX: Wrap the vereinName with Expanded to prevent overflow
          Expanded(
            child: ScaledText(
              vereinName,
              style: UIStyles.subtitleStyle,
              // softWrap is true by default for Text, allowing it to wrap.
              // If you prefer truncation instead of wrapping, you can add:
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            // Changed IntrinsicColumnWidth to FlexColumnWidth for better responsiveness
            0: FlexColumnWidth(
              0.2,
            ), // Small flexible share for the first column
            1: FlexColumnWidth(
              0.2,
            ), // Small flexible share for the second column
            2: FlexColumnWidth(
              0.6,
            ), // The 'Disziplin' name gets the most flexible space
            // Increased FixedColumnWidth to accommodate the IconButton's tap target size
            3: FixedColumnWidth(
              56,
            ), // Standard IconButton needs at least 48px, plus some padding
          },
          // No border parameter, so no border will be shown
          children: [
            TableRow(
              children: [
                // Header for first column: Centered text to align with centered icons below
                Padding(
                  padding: cellContentPadding,
                  child: Center(
                    child: ScaledText(
                      '${seasonInt - 1}',
                      style: UIStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: UIConstants.bodyFontSize,
                        height: UIConstants.spacingXXS,
                      ),
                    ),
                  ),
                ),
                // Header for second column: Centered text to align with centered icons below
                Padding(
                  padding: cellContentPadding,
                  child: Center(
                    child: ScaledText(
                      '$seasonInt',
                      style: UIStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: UIConstants.bodyFontSize,
                        height: UIConstants.spacingXXS,
                      ),
                    ),
                  ),
                ),
                // Header for Disziplin column: Simple padded text
                Container(),
                // Header for delete icon column: Empty cell to match column count
                Container(),
              ],
            ),
            // Map pivot entries to TableRows for content
            ...pivot.entries.map(
              (entry) => TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: firstColumns.containsKey(entry.key)
                          ? const Icon(
                              Icons.check,
                              color: UIConstants.defaultAppColor,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: secondColumns.containsKey(entry.key)
                          ? const Icon(
                              Icons.check,
                              color: UIConstants.defaultAppColor,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: cellContentPadding,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ScaledText(
                          entry.key,
                          style: UIStyles.bodyStyle.copyWith(
                            fontSize: UIConstants.bodyFontSize,
                            height: UIConstants.spacingXXS,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: secondColumns.containsKey(entry.key)
                          ? IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.delete,
                                color: UIConstants.defaultAppColor,
                                size: UIConstants.iconSizeXS,
                              ),
                              onPressed: () => onDelete(entry.key),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Autocomplete and other widgets below the table

        Padding(
          padding: const EdgeInsets.only(top: UIConstants.spacingXS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  TextEditingController? autocompleteController;
                  return Autocomplete<Disziplin>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<Disziplin>.empty();
                      }
                      return disciplines.where((Disziplin d) {
                        return (d.disziplin?.toLowerCase() ?? '').contains(
                              textEditingValue.text.toLowerCase(),
                            ) ||
                            (d.disziplinNr?.toLowerCase() ?? '')
                                .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (Disziplin d) =>
                        ((d.disziplinNr != null && d.disziplinNr!.isNotEmpty)
                            ? '${d.disziplinNr} - '
                            : '') +
                        (d.disziplin ?? ''),
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      autocompleteController = controller;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            height: 32,
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    focusNode.requestFocus();
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    onSelected: (selected) {
                      onAdd(selected);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        try {
                          autocompleteController?.clear();
                        } catch (_) {}
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: UIConstants.spacingM),
            ],
          ),
        ),
      ],
    );
  }
}
