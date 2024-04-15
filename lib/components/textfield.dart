import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FontWeight fontWeight;
  final Icon icon;
  final bool obscureText;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.fontWeight,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      cursorWidth: 1,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        hintText: hintText,
        hintStyle: const TextStyle(
            fontWeight: FontWeight.normal, color: Colors.white30),
        prefixIcon: icon,
      ),
    );
  }
}
