import 'package:flutter/material.dart';

class TrendCustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const TrendCustomButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/trendingpost.png'),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: const Color(0xFF42312A),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Icon(
                Icons.local_fire_department, // fire 아이콘 추가
                color: Colors.black, // 하얀색으로 설정
                size: 40, // 아이콘 크기 설정
              ),
              const Spacer(),
              Text(
                "Trending\nPosts",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
            ],
          ),
        ),
      ),
    );
  }
}
