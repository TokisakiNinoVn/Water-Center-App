import 'package:flutter/material.dart';

class IntroduceCustomerTab extends StatelessWidget {
  const IntroduceCustomerTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giới thiệu"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Center(
          child: Text("Màn hình giới thiệu"),
        ),
      ),
    );
  }
}