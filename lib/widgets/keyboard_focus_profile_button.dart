import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/constants/ui_constants.dart';

/// A FloatingActionButton with Icons.person that shows yellow highlighting when focused via keyboard
class KeyboardFocusProfileButton extends StatefulWidget {
  const KeyboardFocusProfileButton({
    super.key,
    required this.onPressed,
    required this.heroTag,
    this.semanticLabel,
  });

  final VoidCallback onPressed;
  final String heroTag;
  final String? semanticLabel;

  @override
  State<KeyboardFocusProfileButton> createState() => _KeyboardFocusProfileButtonState();
}

class _KeyboardFocusProfileButtonState extends State<KeyboardFocusProfileButton> {
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

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? 'Zurück zum Profil',
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) {
                widget.onPressed();
                return null;
              },
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            onKey: (node, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                widget.onPressed();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Tooltip(
              message: 'Profil',
              child: Padding(
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
                  child: FloatingActionButton(
                    heroTag: widget.heroTag,
                    onPressed: widget.onPressed,
                    backgroundColor: UIConstants.defaultAppColor,
                    child: const Icon(Icons.person, color: UIConstants.whiteColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

