/// หน้าที่หลัก: วาดพื้นหลัง Ocean, ลายน้ำชื่อ และ Dot Grid
part of '../../portfolio_ui.dart';

class _HeroOceanBackdrop extends StatelessWidget {
  const _HeroOceanBackdrop({required this.isDark, required this.watermark});

  final bool isDark;
  final String watermark;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _HeroOceanPainter(isDark: isDark, watermark: watermark),
      child: const SizedBox.expand(),
    ),
  );
}

class _HeroOceanPainter extends CustomPainter {
  const _HeroOceanPainter({required this.isDark, required this.watermark});

  final bool isDark;
  final String watermark;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final deep = isDark ? AppColors.darkOceanDeep : AppColors.lightOceanDeep;
    final mid = isDark ? AppColors.darkOceanMid : AppColors.lightOceanMid;
    final glow = isDark ? AppColors.darkAccent : AppColors.oceanSky;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deep, mid],
        ).createShader(bounds),
    );

    final glowRadius = size.height * .78;
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .48),
      glowRadius,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                glow.withValues(alpha: isDark ? .20 : .15),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * .78, size.height * .48),
                radius: glowRadius,
              ),
            ),
    );

    const spacing = 26.0;
    final dotAlpha = isDark ? .065 : .05;
    final dotPaint = Paint();
    for (var y = 16.0; y < size.height; y += spacing) {
      final fade = (1 - y / size.height * .72).clamp(.15, 1.0).toDouble();
      dotPaint.color = AppColors.darkAccent.withValues(alpha: dotAlpha * fade);
      for (var x = 14.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }

    if (watermark.isEmpty) return;
    canvas.save();
    canvas.clipRect(bounds);
    final style = TextStyle(
      color: Colors.white.withValues(alpha: .05),
      fontSize: (size.width * .12).clamp(48.0, 174.0).toDouble(),
      fontWeight: FontWeight.w900,
      letterSpacing: 4,
    );
    final painter = TextPainter(
      text: TextSpan(text: watermark, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final step = painter.width + 90;
    for (final y in [size.height * .30, size.height * .82]) {
      for (var x = -step; x < size.width; x += step) {
        painter.paint(canvas, Offset(x, y - painter.height / 2));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeroOceanPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.watermark != watermark;
}
