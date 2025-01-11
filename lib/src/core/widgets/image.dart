import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String img;
  final String ext;

  const ImageWidget({super.key, required this.img, required this.ext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/image?img=$img&ext=$ext",
        );
      },
      child: Image.network(
        "https://image.nmb.best/image/$img$ext",
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }
}
