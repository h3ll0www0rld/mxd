import 'package:flutter/material.dart';

class SageWidget extends StatelessWidget {
  const SageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "SAGE",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! - 2,
        ),
      ),
    );
  }
}
