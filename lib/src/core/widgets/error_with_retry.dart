import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorWithRetryWidget extends StatelessWidget {
  final String error;
  final VoidCallback? retry;

  const ErrorWithRetryWidget({
    super.key,
    required this.error,
    required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ErrorWidget(error),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context)!.retry),
        ),
      ],
    );
  }
}
