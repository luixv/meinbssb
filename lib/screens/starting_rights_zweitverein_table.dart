import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/disziplin.dart';

class ZweitvereinTable extends StatelessWidget {
  const ZweitvereinTable({
    super.key,
    required this.xx,
    required this.yy,
    required this.vereinName,
    required this.firstColumns,
    required this.secondColumns,
    required this.pivot,
    required this.disciplines,
    required this.onDelete,
    required this.onAdd,
  });
  final int xx;
  final int yy;
  final String vereinName;
  final Map<String, int?> firstColumns;
  final Map<String, int?> secondColumns;
  final Map<String, int?> pivot;
  final List<Disziplin> disciplines;
  final void Function(String key) onDelete;
  final void Function(Disziplin selected) onAdd;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Row(
        children: [
          ScaledText(
            '• ',
            style: UIStyles.subtitleStyle.copyWith(
              fontSize: (UIStyles.subtitleStyle.fontSize! * 1.5),
              height: 1.0,
            ),
          ),
          // Fix: Wrap the vereinName with Expanded to prevent overflow
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
            0: FlexColumnWidth(0.2),
            1: FlexColumnWidth(0.2),
            2: FlexColumnWidth(0.6),
            3: FixedColumnWidth(56),
          },
          border: TableBorder.all(
            color: UIConstants.cookiesDialogColor,
            width: 4.0,
          ),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: UIConstants.spacingXS,
                  ),
                  child: ScaledText(
                    '${(xx - 1) % 100}/${xx % 100}',
                    style: UIStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: UIConstants.spacingXS,
                  ),
                  child: ScaledText(
                    '${xx % 100}/${yy % 100}',
                    style: UIStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: UIConstants.spacingXS,
                  ),
                  child: ScaledText(
                    'Disziplin',
                    style: UIStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
            ...pivot.entries.map(
              (entry) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: UIConstants.spacingXS,
                    ),
                    child: Center(
                      child: firstColumns.containsKey(entry.key)
                          ? const Icon(
                              Icons.check,
                              color: UIConstants.defaultAppColor,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: UIConstants.spacingXS,
                    ),
                    child: Center(
                      child: secondColumns.containsKey(entry.key)
                          ? const Icon(
                              Icons.check,
                              color: UIConstants.defaultAppColor,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: UIConstants.spacingXS,
                    ),
                    child: ScaledText(
                      entry.key,
                      style: UIStyles.bodyStyle,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: UIConstants.defaultAppColor,
                      ),
                      onPressed: () => onDelete(entry.key),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: UIConstants.spacingS),
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
              const SizedBox(height: UIConstants.spacingL),
            ],
          ),
        ),
      ],
    );
  }
}
