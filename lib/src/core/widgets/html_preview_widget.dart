import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlPreviewWidget extends StatelessWidget {
  final String content;

  const HtmlPreviewWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 100.0,
        ),
        child: HtmlWidget(
          content,
          textStyle: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
          ),
        ),
      ),
    );
  }
}
