import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';

class AgbSection {
  AgbSection({this.title, required this.paragraphs});
  final String? title;
  final List<String> paragraphs;
}

List<AgbSection> parseAgbText(String text) {
  final lines = text.split('\n');
  final List<AgbSection> sections = [];
  String? currentTitle;
  List<String> currentParagraphs = [];
  final sectionHeaderRegex = RegExp(r'^(\d+\.|[A-Z][a-z]+:?)');

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (trimmed.startsWith('Stand:')) {
      currentParagraphs.add(trimmed);
    } else if (sectionHeaderRegex.hasMatch(trimmed) &&
        trimmed.length < UIConstants.maxSectionHeaderLength &&
        !RegExp(r'^\d+\.\d').hasMatch(trimmed) &&
        !RegExp(r'^\d+\.\d+\.\s').hasMatch(trimmed)) {
      if (currentParagraphs.isNotEmpty || currentTitle != null) {
        sections.add(
          AgbSection(title: currentTitle, paragraphs: currentParagraphs),
        );
        currentParagraphs = [];
      }
      currentTitle = trimmed;
    } else {
      currentParagraphs.add(trimmed);
    }
  }
  if (currentParagraphs.isNotEmpty || currentTitle != null) {
    sections.add(
      AgbSection(title: currentTitle, paragraphs: currentParagraphs),
    );
  }
  return sections;
}

Widget buildNumberedParagraph(String para) {
  final regex = RegExp(r'^(\d+(?:\.\d+)*)\.?\s*(.*)');
  final match = regex.firstMatch(para);

  if (match != null) {
    final numbers = match.group(1)!;
    final text = match.group(2)!;
    final hasExtraDot = para.trim().startsWith('$numbers. ');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: hasExtraDot ? '$numbers.' : numbers,
            style: UIStyles.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: UIStyles.bodyStyle.fontSize! * 1.2,
              color: UIConstants.textColor,
            ),
          ),
          TextSpan(
            text: hasExtraDot ? ' $text' : ' $text',
            style: UIStyles.bodyStyle,
          ),
        ],
      ),
    );
  }
  return Text(para, style: UIStyles.bodyStyle);
}
