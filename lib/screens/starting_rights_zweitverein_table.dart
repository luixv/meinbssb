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
      title: Row(
        children: [
          ScaledText(
            '• ',
            style: UIStyles.subtitleStyle.copyWith(
              fontSize: (UIStyles.subtitleStyle.fontSize! * 1.5),
              height: 1.0,
            ),
          ),
          ScaledText(
            vereinName,
            style: UIStyles.subtitleStyle,
          ),
        ],
      ),
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: FlexColumnWidth(),
          },
          border: TableBorder.all(
            color: Colors.transparent,
          ),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  child: ScaledText(
                    '$xx',
                    style: UIStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  child: ScaledText(
                    '$yy',
                    style: UIStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
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
                    padding: const EdgeInsets.all(UIConstants.spacingS),
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
                    padding: const EdgeInsets.all(UIConstants.spacingS),
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
                    padding: const EdgeInsets.all(UIConstants.spacingS),
                    child: ScaledText(
                      entry.key,
                      style: UIStyles.bodyStyle,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: UIConstants.defaultAppColor,
                    ),
                    onPressed: () => onDelete(entry.key),
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
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Disziplin hinzufügen',
                          border: OutlineInputBorder(),
                        ),
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
