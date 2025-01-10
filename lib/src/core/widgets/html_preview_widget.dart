import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlPreviewWidget extends StatefulWidget {
  final String content;

  const HtmlPreviewWidget({super.key, required this.content});

  @override
  State<HtmlPreviewWidget> createState() => _HtmlPreviewWidgetState();
}

class _HtmlPreviewWidgetState extends State<HtmlPreviewWidget> {
  final GlobalKey _contentKey = GlobalKey();
  bool _isOverflowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final contentHeight = renderBox.size.height;
        final containerHeight = 100.0;
        setState(() {
          _isOverflowed = contentHeight > containerHeight;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 100.0,
      ),
      child: ClipRect(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: HtmlWidget(
                key: _contentKey,
                widget.content,
                textStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                ),
              ),
            ),
            if (_isOverflowed)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.0),
                  ),
                  child: Container(
                    height: 20.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).cardColor.withOpacity(0.0),
                          Theme.of(context).cardColor.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
