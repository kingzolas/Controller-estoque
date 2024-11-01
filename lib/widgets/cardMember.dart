import 'package:flutter/material.dart';

class Cardmember extends StatefulWidget {
  const Cardmember({super.key});

  @override
  State<Cardmember> createState() => _CardmemberState();
}

class _CardmemberState extends State<Cardmember> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.amber,
      content: Container(
        color: Colors.amber,
        height: 300,
        width: 300,
      ),
    );
  }
}
