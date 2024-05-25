import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/styles/colors.dart';

class CommonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Icon? icon;
  final bool obscureText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final String? Function(String? value)? validator;
  final int? minLines;
  final int? maxLines;

  const CommonTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.icon,
      this.obscureText = false,
      this.style,
      this.hintStyle,
      this.validator,
      this.minLines = 1,
      this.maxLines = 1});

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      controller: widget.controller,
      style: widget.style ?? const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      cursorWidth: 1,
      cursorErrorColor: Colors.white,
      validator: widget.validator,
      obscureText: widget.obscureText ? isObscured : false,
      decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ??
              const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.white30),
          errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: CustomColor.lightRed)),
          focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: CustomColor.lightRed)),
          errorStyle: const TextStyle(color: CustomColor.lightRed),
          errorMaxLines: 3,
          prefixIcon: widget.icon,
          suffixIcon: widget.obscureText
              ? CommonButton(
                  onPressed: () {
                    setState(() {
                      isObscured = !isObscured;
                    });
                  },
                  isIcon: true,
                  icon: isObscured
                      ? const Icon(
                          Icons.visibility,
                          color: Colors.white38,
                          size: 20,
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: Colors.white38,
                          size: 20,
                        ),
                  size: const Size(40, 40),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                )
              : null),
    );
  }
}
