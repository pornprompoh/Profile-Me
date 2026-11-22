/// หน้าที่หลัก: แสดงตัวกรองหมวดหมู่แบบ Dropdown แบบกว้างกดง่ายบนมือถือ
part of '../../portfolio_ui.dart';

class _MobileCategoryDropdown extends StatefulWidget {
  const _MobileCategoryDropdown({
    required this.projects,
    required this.categories,
    required this.selected,
    required this.locale,
    required this.onSelected,
  });

  final List<Project> projects;
  final List<String> categories;
  final String selected;
  final AppLocale locale;
  final ValueChanged<String> onSelected;

  @override
  State<_MobileCategoryDropdown> createState() =>
      _MobileCategoryDropdownState();
}

class _MobileCategoryDropdownState extends State<_MobileCategoryDropdown> {
  final MenuController _menuController = MenuController();
  final ScrollController _menuScrollController = ScrollController();
  bool _isOpen = false;

  @override
  void dispose() {
    _menuScrollController.dispose();
    super.dispose();
  }

  int _countFor(String category) => widget.projects
      .where(
        (project) =>
            (widget.locale == AppLocale.th
                ? project.category.th
                : project.category.en) ==
            category,
      )
      .length;

  String _allLabel(BuildContext context) =>
      widget.locale == AppLocale.th ? 'ทั้งหมด' : 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLabel = _allLabel(context);
    final selectedLabel = widget.selected == 'all'
        ? '$allLabel (${widget.projects.length})'
        : '${widget.selected} (${_countFor(widget.selected)})';
    final itemCount = widget.categories.length + 1;
    final menuHeight = (itemCount * 44.0).clamp(44.0, 260.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final triggerWidth = constraints.maxWidth;
        final menuWidth = triggerWidth;
        final needsScroll = itemCount * 44 > 260;

        return MenuAnchor(
          controller: _menuController,
          alignmentOffset: const Offset(0, 6),
          consumeOutsideTap: true,
          onOpen: () => setState(() => _isOpen = true),
          onClose: () => setState(() => _isOpen = false),
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
            maximumSize: WidgetStatePropertyAll(Size(menuWidth, 260)),
            backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(8),
            shadowColor: WidgetStatePropertyAll(
              theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: .38)
                  : theme.colorScheme.shadow.withValues(alpha: .16),
            ),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
          ),
          menuChildren: [
            SizedBox(
              width: menuWidth,
              height: menuHeight,
              child: Scrollbar(
                controller: _menuScrollController,
                thumbVisibility: needsScroll,
                thickness: 3,
                radius: const Radius.circular(4),
                child: ListView(
                  controller: _menuScrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  children: [
                    _buildMenuItem(
                      context: context,
                      value: 'all',
                      label: '$allLabel (${widget.projects.length})',
                      selected: widget.selected == 'all',
                      triggerWidth: menuWidth,
                    ),
                    for (final category in widget.categories)
                      _buildMenuItem(
                        context: context,
                        value: category,
                        label: '$category (${_countFor(category)})',
                        selected: widget.selected == category,
                        triggerWidth: menuWidth,
                      ),
                  ],
                ),
              ),
            ),
          ],
          builder: (context, controller, child) => SizedBox(
            height: 48,
            width: double.infinity,
            child: InkWell(
              onTap: () => _isOpen ? controller.close() : controller.open(),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _isOpen ? .5 : 0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String value,
    required String label,
    required bool selected,
    required double triggerWidth,
  }) {
    final theme = Theme.of(context);
    final accent = theme.brightness == Brightness.dark
        ? AppTheme.darkAccent
        : AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: MenuItemButton(
        onPressed: () => widget.onSelected(value),
        closeOnActivate: true,
        style: ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size(triggerWidth - 8, 42)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          maximumSize: WidgetStatePropertyAll(Size(triggerWidth - 8, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 10),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (selected) {
              return accent.withValues(
                alpha: theme.brightness == Brightness.dark ? .18 : .12,
              );
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStatePropertyAll(
            selected ? accent : theme.colorScheme.onSurface,
          ),
          overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: .08)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_rounded, size: 18, color: accent),
            ],
          ],
        ),
      ),
    );
  }
}
