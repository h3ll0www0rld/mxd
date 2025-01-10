// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String title;

  const TitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
      ),
    );
  }
}

class InformationText extends StatelessWidget {
  final String information;

  const InformationText({super.key, required this.information});

  @override
  Widget build(BuildContext context) {
    return Text(
      information,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
      ),
    );
  }
}

class AdminText extends StatelessWidget {
  final String user_hash;

  const AdminText({super.key, required this.user_hash});

  @override
  Widget build(BuildContext context) {
    return Text(
      user_hash,
      style: TextStyle(
        color: Colors.red,
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
      ),
    );
  }
}

class POText extends StatelessWidget {
  final String user_hash;

  const POText({super.key, required this.user_hash});

  @override
  Widget build(BuildContext context) {
    return Text(
      user_hash,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
      ),
    );
  }
}
