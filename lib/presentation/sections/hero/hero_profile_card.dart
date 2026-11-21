/// หน้าที่หลัก: แสดงภาพโปรไฟล์พร้อม Caption และเปิด Lightbox
part of '../../portfolio_ui.dart';

class _HeroProfileCard extends StatelessWidget {
  const _HeroProfileCard({
    required this.paths,
    required this.width,
    required this.caption,
  });

  final List<String> paths;
  final double width;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: paths.isEmpty
                ? null
                : () => showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => _Lightbox(images: paths),
                  ),
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .48),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .24),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: AppColors.oceanSky.withValues(alpha: .16),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (paths.isNotEmpty)
                      Image.asset(
                        paths.first,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, _, _) => _fallback(context),
                      )
                    else
                      _fallback(context),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkOceanDeep.withValues(alpha: .88),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .24),
                          ),
                        ),
                        child: Text(
                          caption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Center(child: Icon(Icons.person_outline_rounded, size: 64)),
  );
}
