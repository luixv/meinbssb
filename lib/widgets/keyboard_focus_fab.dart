import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';

/// A FloatingActionButton that shows yellow highlighting when focused via keyboard
class KeyboardFocusFAB extends StatefulWidget {
  const KeyboardFocusFAB({
    super.key,
    required this.heroTag,
    required this.onPressed,
    this.icon,
    this.child,
    this.tooltip,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.iconColor,
    this.mini = false,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  final String heroTag;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;
  final String? tooltip;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool mini;

  @override
  State<KeyboardFocusFAB> createState() => _KeyboardFocusFABState();
}

class _KeyboardFocusFABState extends State<KeyboardFocusFAB> {
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
    final isKeyboardMode = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final hasKeyboardFocus = _isFocused && isKeyboardMode;

    Widget button = FloatingActionButton(
      focusNode: _focusNode,
      heroTag: widget.heroTag,
      onPressed: widget.onPressed,
      backgroundColor: widget.backgroundColor ?? UIConstants.defaultAppColor,
      mini: widget.mini,
      child: widget.child ??
          (widget.icon != null
              ? Icon(widget.icon, color: widget.iconColor ?? UIConstants.whiteColor)
              : null),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    Widget result = Padding(
      padding: hasKeyboardFocus ? const EdgeInsets.all(4.0) : EdgeInsets.zero,
      child: Container(
        decoration: hasKeyboardFocus
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.yellow.shade700,
                  width: 3.0,
                ),
              )
            : null,
        child: button,
      ),
    );

    if (widget.semanticLabel != null || widget.semanticHint != null) {
      result = Semantics(
        button: true,
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        child: result,
      );
    }

    return result;
  }
}

