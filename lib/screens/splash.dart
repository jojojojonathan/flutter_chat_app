import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text('UniChat'),
      //   centerTitle: true,
      //   backgroundColor: Theme.of(context).colorScheme.primary
      // ),
      body: Center(child: Text('Loading...'),),
    );
  }
}