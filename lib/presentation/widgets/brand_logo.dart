/// หน้าที่หลัก: แสดงรูปแบรนด์และชื่อ Pornprom เป็นก้อนเดียวบน Navbar และ Drawer
part of '../portfolio_ui.dart';

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({
    required this.brandName,
    required this.iconSize,
    required this.textStyle,
  });

  final String brandName;
  final double iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: .08)
                  : Colors.white.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: .18)
                    : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/my_content/images/brand_icon.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        SizedBox(width: iconSize < 24.5 ? 7 : 8),
        Text(
          brandName,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: textStyle,
        ),
      ],
    );
  }
}
