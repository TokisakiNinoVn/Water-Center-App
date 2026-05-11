import 'package:flutter/material.dart';

class SupportCustomerTab extends StatelessWidget {
  const SupportCustomerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hỗ trợ"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Center(
          child: Text("Màn hình hỗ trợ"),
        ),
      ),
    );
  }
}