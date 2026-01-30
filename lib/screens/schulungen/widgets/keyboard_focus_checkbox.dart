import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom Checkbox widget with keyboard-only focus highlighting
class KeyboardFocusCheckbox extends StatefulWidget {
  const KeyboardFocusCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  State<KeyboardFocusCheckbox> createState() => _KeyboardFocusCheckboxState();
}

class _KeyboardFocusCheckboxState extends State<KeyboardFocusCheckbox> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if focus is from keyboard navigation
    final isKeyboardMode =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final hasKeyboardFocus = _isFocused && isKeyboardMode;

    return Semantics(
      label: widget.label,
      child: Focus(
        focusNode: _focusNode,
        onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            widget.onChanged(!widget.value);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          decoration: hasKeyboardFocus
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.yellow.shade700,
                    width: 3.0,
                  ),
                )
              : null,
          child: Checkbox(value: widget.value, onChanged: widget.onChanged),
        ),
      ),
    );
  }
}
