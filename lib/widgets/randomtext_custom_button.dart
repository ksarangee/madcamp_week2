import 'package:flutter/material.dart';

class RandomtextCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? iconOnPressed;

  const RandomtextCustomButton({
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
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/randompost.png'), // 이미지 경로 설정
            fit: BoxFit.cover, // 이미지를 버튼 크기에 맞게 조절
          ),
          border: Border.all(
            color: const Color(0xFF42312A), // 테두리 색상 설정
            width: 2.0, // 테두리 두께 설정
          ),
          borderRadius: BorderRadius.circular(15), // 둥근 모서리 설정
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // 버튼의 배경을 투명하게 설정
            shadowColor: Colors.transparent, // 버튼의 그림자를 투명하게 설정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10), // 위쪽 간격 추가
                if (icon != null) ...[
                  IconButton(
                    icon: Icon(icon),
                    onPressed: iconOnPressed ?? onPressed,
                    color: textColor ?? Colors.white,
                  ),
                  const SizedBox(height: 0.1), // 아이콘과 텍스트 사이의 간격
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(), // 아래 텍스트를 아래쪽으로 밀기 위한 Spacer
                Text(
                  "Random\nPost",
                  style: TextStyle(
                    color: Colors.black, // 검은색 텍스트
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3), // 아래쪽 간격 추가
              ],
            ),
          ),
        ),
      ),
    );
  }
}
