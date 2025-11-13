import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/models/disziplin_data.dart';
import 'package:flutter/services.dart';

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

    return Semantics(
      container: true,
      label: 'Zweitverein $vereinName',
      child: ExpansionTile(
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
                        child:
                            firstColumns.containsKey(entry.key)
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
                        child:
                            secondColumns.containsKey(entry.key)
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
                        child:
                            secondColumns.containsKey(entry.key)
                                ? Semantics(
                                  button: true,
                                  label: 'Entfernen',
                                  hint:
                                      'Disziplin ${entry.key} aus Zweitverein entfernen',
                                  child: IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Löschen',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: UIConstants.defaultAppColor,
                                      size: UIConstants.iconSizeXS,
                                    ),
                                    onPressed: () => onDelete(entry.key),
                                  ),
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
                ZveAutocompleteField(
                  disciplines: disciplines,
                  onAdd: (selected) {
                    //debugPrint('Selected discipline: $selected');
                    onAdd(selected);
                  },
                  onTabToNextTable: () {
                    //debugPrint('TAB in empty autocomplete: move to next ZVE');
                  },
                ),
                const SizedBox(height: UIConstants.spacingM),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Local stateful widget for improved autocomplete keyboard navigation
class ZveAutocompleteField extends StatefulWidget {
  const ZveAutocompleteField({
    required this.disciplines,
    required this.onAdd,
    required this.onTabToNextTable,
    super.key,
  });
  final List<Disziplin> disciplines;
  final void Function(Disziplin) onAdd;
  final VoidCallback onTabToNextTable;

  @override
  State<ZveAutocompleteField> createState() => ZveAutocompleteFieldState();
}

class ZveAutocompleteFieldState extends State<ZveAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _highlightedIndex = -1;
  List<Disziplin> _suggestions = [];
  bool _showOverlay = false;
  bool _justSelectedWithKeyboard = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHighlightedItem() {
    if (_highlightedIndex < 0 || !_scrollController.hasClients) return;
    
    // Approximate item height (padding + text)
    const double itemHeight = 40.0;
    final double offset = _highlightedIndex * itemHeight;
    final double viewportHeight = _scrollController.position.viewportDimension;
    
    // Scroll to keep the item visible
    if (offset < _scrollController.offset) {
      // Item is above viewport, scroll up
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else if (offset + itemHeight > _scrollController.offset + viewportHeight) {
      // Item is below viewport, scroll down
      _scrollController.animateTo(
        offset + itemHeight - viewportHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateSuggestions(String pattern) {
    //debugPrint('Suggestions update: pattern="$pattern"');
    setState(() {
      if (pattern.isEmpty) {
        _suggestions = [];
        _showOverlay = false;
        _highlightedIndex = -1;
      } else {
        _suggestions =
            widget.disciplines
                .where(
                  (d) =>
                      (d.disziplin?.toLowerCase() ?? '').contains(
                        pattern.toLowerCase(),
                      ) ||
                      (d.disziplinNr?.toLowerCase() ?? '').contains(
                        pattern.toLowerCase(),
                      ),
                )
                .toList();
        _showOverlay = _suggestions.isNotEmpty;
        _highlightedIndex = _suggestions.isNotEmpty ? 0 : -1;
      }
      //debugPrint('Suggestions: count=${_suggestions.length}, overlay=$_showOverlay',);
    });
  }

  void _handleKey(RawKeyEvent event) {
    //debugPrint('RawKeyboardListener event: ${event.logicalKey}, text="${_controller.text}"',);
    if (event is RawKeyDownEvent) {
      if (_controller.text.isEmpty &&
          event.logicalKey == LogicalKeyboardKey.tab) {
        //debugPrint('TAB pressed in empty autocomplete');
        widget.onTabToNextTable();
        return;
      }
      if (_showOverlay && _suggestions.isNotEmpty) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          setState(() {
            _highlightedIndex = (_highlightedIndex + 1) % _suggestions.length;
            // debugPrint('TAB cycles to index $_highlightedIndex');
          });
          // Scroll to keep highlighted item visible
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToHighlightedItem();
          });
        } else if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (_highlightedIndex >= 0 &&
              _highlightedIndex < _suggestions.length) {
            final selected = _suggestions[_highlightedIndex];
            //debugPrint('ENTER selects: $selected');
            _justSelectedWithKeyboard = true;
            widget.onAdd(selected);
            _controller.clear();
            setState(() {
              _showOverlay = false;
              _suggestions = [];
              _highlightedIndex = -1;
            });
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              _justSelectedWithKeyboard = false;
            });
          }
        }
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        // If overlay not shown, try to match by text
        final value = _controller.text.trim();
        Disziplin? match;
        for (final d in widget.disciplines) {
          final label =
              (((d.disziplinNr != null && d.disziplinNr!.isNotEmpty)
                          ? '${d.disziplinNr} - '
                          : '') +
                      (d.disziplin ?? ''))
                  .trim()
                  .toLowerCase();
          if (label == value.toLowerCase()) {
            match = d;
            break;
          }
        }
        if (match != null) {
          //debugPrint('ENTER (no overlay) selects: $match');
          widget.onAdd(match);
          _controller.clear();
          setState(() {
            _showOverlay = false;
            _suggestions = [];
            _highlightedIndex = -1;
          });
          FocusScope.of(context).unfocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Disziplin hinzufügen',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: null,
                ),
                onChanged: _updateSuggestions,
                onSubmitted: (value) {
                  // Handle Enter key press
                  if (_showOverlay && _suggestions.isNotEmpty && _highlightedIndex >= 0) {
                    final selected = _suggestions[_highlightedIndex];
                    widget.onAdd(selected);
                    _controller.clear();
                    setState(() {
                      _showOverlay = false;
                      _suggestions = [];
                      _highlightedIndex = -1;
                    });
                  } else if (value.trim().isNotEmpty) {
                    // Try to find exact match if overlay is not shown
                    final match = widget.disciplines.firstWhere(
                      (d) {
                        final label = (((d.disziplinNr != null && d.disziplinNr!.isNotEmpty)
                                    ? '${d.disziplinNr} - '
                                    : '') +
                                (d.disziplin ?? ''))
                            .trim()
                            .toLowerCase();
                        return label == value.trim().toLowerCase();
                      },
                      orElse: () => Disziplin(disziplinId: -1, disziplinNr: null, disziplin: null),
                    );
                    if (match.disziplinId != -1) {
                      widget.onAdd(match);
                      _controller.clear();
                      setState(() {
                        _showOverlay = false;
                        _suggestions = [];
                        _highlightedIndex = -1;
                      });
                    }
                  }
                },
              ),
              if (_showOverlay)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 150,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, idx) {
                          final suggestion = _suggestions[idx];
                          final isHighlighted = idx == _highlightedIndex;
                          return InkWell(
                            onTap: () {
                              if (_justSelectedWithKeyboard) return;
                              widget.onAdd(suggestion);
                              _controller.clear();
                              setState(() {
                                _showOverlay = false;
                                _suggestions = [];
                                _highlightedIndex = -1;
                              });
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              color:
                                  isHighlighted
                                      ? Colors.blue.shade100
                                      : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Text(
                                ((suggestion.disziplinNr != null &&
                                            suggestion.disziplinNr!.isNotEmpty
                                        ? '${suggestion.disziplinNr} - '
                                        : '') +
                                    (suggestion.disziplin ?? '')),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
