import 'package:flutter/material.dart';

class NewPublicTab extends StatelessWidget {
  const NewPublicTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Các tin tức mới"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Center(
          child: Text("Màn hình tin tức"),
        ),
      ),
    );
  }
}