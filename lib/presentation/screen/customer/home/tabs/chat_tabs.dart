import 'package:flutter/material.dart';

class ChatCustomerTab extends StatelessWidget {
  const ChatCustomerTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Center(
          child: Text("Màn hình chat"),
        ),
      ),
    );
  }
}