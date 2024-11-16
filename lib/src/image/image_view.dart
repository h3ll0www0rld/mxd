import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String imageName;
  final String imageExt;

  const ImageView({super.key, required this.imageName, required this.imageExt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('查看图片'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(
            "https://image.nmb.best/image/$imageName$imageExt",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
