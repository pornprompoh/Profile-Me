// หน้าที่หลัก: วาดลายจุดและ Gradient พื้นหลัง Hero ให้จางกลืนกับหน้า
part of '../../../main.dart';

class _HeroDotGridBackground extends StatelessWidget {
  const _HeroDotGridBackground({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDark ? AppTheme.darkAccent : AppTheme.primary;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: isDark ? const [0, .72, 1] : const [0, .48, .78, 1],
              colors: isDark
                  ? [
                      theme.colorScheme.primaryContainer.withValues(alpha: .30),
                      theme.scaffoldBackgroundColor.withValues(alpha: .45),
                      Colors.transparent,
                    ]
                  : [
                      theme.colorScheme.primaryContainer.withValues(alpha: .12),
                      theme.scaffoldBackgroundColor.withValues(alpha: .10),
                      theme.scaffoldBackgroundColor.withValues(alpha: .05),
                      Colors.transparent,
                    ],
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, .62, 1],
            colors: [Colors.white, Colors.white, Colors.transparent],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: CustomPaint(
            painter: _HeroDotGridPainter(
              accent.withValues(alpha: isDark ? .07 : .05),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _HeroDotGridPainter extends CustomPainter {
  const _HeroDotGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 24.0;
    for (var y = 16.0; y < size.height; y += spacing) {
      for (var x = 12.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeroDotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}
