import 'package:flutter/material.dart';
import 'package:mxd/src/core/widgets/text.dart';
import 'package:mxd/src/models/cookie_card.dart';

class CookieCard extends StatelessWidget {
  final CookieCardModel cookie;
  final ValueChanged<CookieCardModel> onChanged;
  final VoidCallback onDelete;

  const CookieCard({
    super.key,
    required this.cookie,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ListTile(
        title: WidgetText(text: cookie.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: cookie.isEnabled,
              onChanged: (value) {
                if (value != null) {
                  onChanged(cookie);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
