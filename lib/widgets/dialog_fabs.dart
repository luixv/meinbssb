import 'package:flutter/material.dart';

/// A reusable widget for arranging FloatingActionButtons inside dialogs vertically.
///
/// Note: For absolute positioning, wrap DialogFABs in a Positioned widget at the bottom right of a Stack.
///
/// Usage:
/// ```dart
/// Positioned(
///   bottom: ...,
///   right: ...,
///   child: DialogFABs(
///     children: [ ... ],
///   ),
/// )
/// ```
class DialogFABs extends StatelessWidget {

  const DialogFABs({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.end,
  });
  final List<Widget> children;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          children[i],
        ],
      ],
    );
  }
}
