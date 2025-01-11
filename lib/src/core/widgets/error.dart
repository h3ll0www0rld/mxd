import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorInfoWidget extends StatelessWidget {
  final String error;

  const ErrorInfoWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red,size: 50.0,),
        Text(error),
      ],
    );
  }
}

class ErrorInfoWithRetryWidget extends StatelessWidget {
  final String error;
  final VoidCallback? retry;

  const ErrorInfoWithRetryWidget({
    super.key,
    required this.error,
    required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ErrorInfoWidget(error: error),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: retry,
          child: Text(AppLocalizations.of(context)!.retry),
        ),
      ],
    );
  }
}
