// หน้าที่หลัก: แสดงรูปโปรไฟล์พร้อมวงแหวน Accent, Glow และเปิด Lightbox
part of '../../../main.dart';

class _ProfileImage extends StatelessWidget {
  const _ProfileImage(this.path, {required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppTheme.darkAccent : AppTheme.primary;
    final surface = theme.colorScheme.surfaceContainerHighest;
    return SizedBox.square(
      dimension: size + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? .20 : .15),
                  Colors.transparent,
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: path.isEmpty
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => _Lightbox(images: [path]),
                    ),
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surface,
                  border: Border.all(
                    color: accent.withValues(alpha: .38),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: isDark ? .17 : .13),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? .20 : .08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? surface : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: path.isNotEmpty
                        ? Image.asset(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallback(surface),
                          )
                        : _fallback(surface),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(Color surface) => ColoredBox(
    color: surface,
    child: const Center(child: Icon(Icons.person_outline_rounded, size: 56)),
  );
}
