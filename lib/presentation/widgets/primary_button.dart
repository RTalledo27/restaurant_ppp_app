import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 216,
    this.colorButton = const Color(0xFFC45525),
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed; // Cambiado a nullable
  final double width;
  final Color colorButton;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorButton,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(
              24)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}