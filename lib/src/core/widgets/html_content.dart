import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/main.dart';
import 'package:mxd/src/models/ref_dialog.dart';
import 'package:mxd/src/views/thread/widgets/ref_dialog.dart';


class HtmlContentWidget extends StatelessWidget {
  final String content;

  const HtmlContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      content,
      customWidgetBuilder: (element) {
        if (element.localName == 'font' &&
            element.attributes['color'] == '#789922' &&
            element.text.startsWith('>>No.')) {
          final refId = _extractPostId(element.text);
          if (refId != null) {
            return GestureDetector(
              onTap: () {
                _showRefDialog(context, refId);
              },
              child: Text(
                ">>No.$refId",
                style: TextStyle(
                    color: Color(0xFF789922),
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
              ),
            );
          }
        }
        return null;
      },
    );
  }

  int? _extractPostId(String text) {
    final RegExp regExp = RegExp(r'No\.(\d+)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      final refIdStr = match.group(1);
      if (refIdStr != null) {
        return int.tryParse(refIdStr);
      }
    }
    return null;
  }

  void _showRefDialog(BuildContext context, int refID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: nmbxdClient.fetchRefByID(refID, context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final refModel = RefModel.fromJson(snapshot.data!);
              return RefDialog(refModel: refModel);
            } else {
              return Center(child: Text('Unexpected error occurred.'));
            }
          },
        );
      },
    );
  }
}
