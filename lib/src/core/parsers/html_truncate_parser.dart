import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html_dom;

class HtmlTruncateParser {
  /// 按行数截断 HTML 内容
  String truncateHtml(
      String htmlContent, int maxLines, TextStyle textStyle, double maxWidth) {
    final htmlDocument = html_dom.Document.html(htmlContent);
    final buffer = StringBuffer();
    int currentLines = 0;

    void traverse(html_dom.Node node, List<String> openTags) {
      if (node is html_dom.Text) {
        final text = node.text.trim();
        final lines = _measureTextLines(
          text: buffer.toString() + text,
          textStyle: textStyle,
          maxWidth: maxWidth,
        );

        if (lines > maxLines) {
          final remainingText = _truncateTextToLines(
            text: text,
            currentLines: currentLines,
            maxLines: maxLines,
            textStyle: textStyle,
            maxWidth: maxWidth,
          );
          buffer.write(remainingText);
          currentLines = maxLines;
        } else {
          buffer.write(text);
          currentLines = lines;
        }
        return;
      }

      if (node is html_dom.Element) {
        buffer
            .write('<${node.localName}${_formatAttributes(node.attributes)}>');
        openTags.add(node.localName!);

        for (final child in node.nodes) {
          traverse(child, openTags);
          if (currentLines >= maxLines) break;
        }

        // 关闭当前标签
        if (openTags.isNotEmpty) {
          final tag = openTags.removeLast();
          buffer.write('</$tag>');
        }
      }
    }

    final openTags = <String>[];
    for (final node in htmlDocument.body!.nodes) {
      traverse(node, openTags);
      if (currentLines >= maxLines) break;
    }

    return _sanitizeHtml(buffer.toString());
  }

  /// 格式化 HTML 属性
  String _formatAttributes(Map<Object, String> attributes) {
    if (attributes.isEmpty) return '';

    final attributesString = attributes.entries
        .map((e) => '${e.key.toString()}="${e.value}"')
        .join(' ');

    return attributesString.isNotEmpty ? ' $attributesString' : '';
  }

  // 计算文本的行数
  int _measureTextLines({
    required String text,
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final span = TextSpan(text: text, style: textStyle);
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return tp.computeLineMetrics().length;
  }

  // 截断文本至指定行数
  String _truncateTextToLines({
    required String text,
    required int currentLines,
    required int maxLines,
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final testText = buffer.toString() + text[i];
      final lines = _measureTextLines(
        text: testText,
        textStyle: textStyle,
        maxWidth: maxWidth,
      );
      if (lines > maxLines) break;
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  // 去掉多余的换行符或 <br> 标签
  String _sanitizeHtml(String html) {
    return html.replaceAll(RegExp(r'<br\s*/?>'), '').trim();
  }
}
