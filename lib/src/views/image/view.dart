import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImageView extends StatelessWidget {
  final String imageName;
  final String imageExt;

  static const routeName = '/image';

  const ImageView({super.key, required this.imageName, required this.imageExt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.viewImage)),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          clipBehavior: Clip.none,
          child: Container(
            alignment: Alignment.center,
            child: Image.network(
              "https://image.nmb.best/image/$imageName$imageExt",
              fit: BoxFit.contain,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return ErrorWidget(
                    AppLocalizations.of(context)!.imageLoadError);
              },
            ),
          ),
        ),
      ),
    );
  }
}
