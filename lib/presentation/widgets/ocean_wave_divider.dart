/// หน้าที่หลัก: วาดคลื่นทะเลนิ่งซ้อนสองชั้นคั่นระหว่าง Section
part of '../portfolio_ui.dart';

class _OceanWaveDivider extends StatelessWidget {
  const _OceanWaveDivider({required this.isDark, required this.isFooterEdge});

  final bool isDark;
  final bool isFooterEdge;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final ocean = isFooterEdge
        ? (isDark ? AppColors.darkOceanDeep : AppColors.lightOceanDeep)
        : (isDark ? AppColors.darkOceanMid : AppColors.lightOceanMid);
    final surface = Theme.of(context).scaffoldBackgroundColor;
    final accent = isDark ? AppColors.darkAccent : AppColors.oceanSky;
    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: width < LayoutTokens.mobileBreakpoint ? 54 : 78,
        child: CustomPaint(
          painter: _OceanWavePainter(
            ocean: ocean,
            surface: surface,
            accent: accent,
            isFooterEdge: isFooterEdge,
          ),
        ),
      ),
    );
  }
}

class _OceanWavePainter extends CustomPainter {
  const _OceanWavePainter({
    required this.ocean,
    required this.surface,
    required this.accent,
    required this.isFooterEdge,
  });

  final Color ocean;
  final Color surface;
  final Color accent;
  final bool isFooterEdge;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = surface);
    canvas.save();
    if (isFooterEdge) {
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }

    final mainWave = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * .48)
      ..cubicTo(
        size.width * .73,
        size.height * .27,
        size.width * .34,
        size.height * .72,
        0,
        size.height * .38,
      )
      ..close();
    canvas.drawPath(mainWave, Paint()..color = ocean);

    final accentWave = Path()
      ..moveTo(0, size.height * .38)
      ..cubicTo(
        size.width * .30,
        size.height * .64,
        size.width * .68,
        size.height * .20,
        size.width,
        size.height * .48,
      )
      ..lineTo(size.width, size.height * .65)
      ..cubicTo(
        size.width * .64,
        size.height * .45,
        size.width * .34,
        size.height * .82,
        0,
        size.height * .57,
      )
      ..close();
    canvas.drawPath(accentWave, Paint()..color = accent.withValues(alpha: .18));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OceanWavePainter oldDelegate) =>
      oldDelegate.ocean != ocean ||
      oldDelegate.surface != surface ||
      oldDelegate.accent != accent ||
      oldDelegate.isFooterEdge != isFooterEdge;
}
