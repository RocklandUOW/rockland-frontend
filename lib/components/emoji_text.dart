import 'package:flutter/material.dart';

// credit to Jack' on Stackoverflow, 
// https://stackoverflow.com/a/68051808/25049731
class TextWithEmojis extends StatelessWidget {
  const TextWithEmojis({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
  });

  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildText(),
    );
  }

  TextSpan _buildText() {
    final children = <TextSpan>[];
    final runes = text.runes;

    for (int i = 0; i < runes.length; /* empty */) {
      int current = runes.elementAt(i);

      // we assume that everything that is not
      // in Extended-ASCII set is an emoji...
      final isEmoji = current > 255;
      final shouldBreak = isEmoji ? (x) => x <= 255 : (x) => x > 255;

      final chunk = <int>[];
      while (!shouldBreak(current)) {
        chunk.add(current);
        if (++i >= runes.length) break;
        current = runes.elementAt(i);
      }

      children.add(
        TextSpan(
          text: String.fromCharCodes(chunk),
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontFamily: isEmoji ? 'NotoSansEmoji' : 'Lato',
          ),
        ),
      );
    }

    return TextSpan(children: children);
  }
}