/// หน้าที่หลัก: แสดงปุ่มกลับด้านบนก่อน Footer
part of '../portfolio_ui.dart';

class _BackToTopButton extends StatelessWidget {
  const _BackToTopButton({required this.locale, required this.onPressed});

  final AppLocale locale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: colors.surface.withValues(alpha: .78),
            shape: StadiumBorder(
              side: BorderSide(color: colors.primary.withValues(alpha: .28)),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(999),
              hoverColor: colors.primary.withValues(alpha: .08),
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.backToTop(locale),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
