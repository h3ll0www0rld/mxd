import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/src/core/parsers/html_truncate_parser.dart';

class HtmlPreviewWidget extends StatefulWidget {
  final String content;

  const HtmlPreviewWidget({super.key, required this.content});

  @override
  State<HtmlPreviewWidget> createState() => _HtmlPreviewWidgetState();
}

class _HtmlPreviewWidgetState extends State<HtmlPreviewWidget> {
  final GlobalKey _contentKey = GlobalKey();
  String _truncatedContent = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _truncateHtmlContent();
    });
  }

  void _truncateHtmlContent() {
    final renderBox =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final maxWidth = renderBox.size.width;
      final parser = HtmlTruncateParser();
      final truncatedHtml = parser.truncateHtml(
        widget.content,
        5, // 最大行数
        TextStyle(
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize!,
        ),
        maxWidth,
      );

      setState(() {
        _truncatedContent = truncatedHtml;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: HtmlWidget(
            key: _contentKey,
            _truncatedContent.isEmpty ? widget.content : _truncatedContent,
            textStyle: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          ),
        );
      },
    );
  }
}
