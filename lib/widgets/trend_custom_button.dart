import 'package:flutter/material.dart';

class TrendCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? iconOnPressed;

  const TrendCustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC4E7FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconButton(
                  icon: Icon(icon),
                  onPressed: iconOnPressed ?? onPressed,
                  color: textColor ?? Colors.white,
                ),
                const SizedBox(height: 8), // 아이콘과 텍스트 사이의 간격
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Color(0xFF898989),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
