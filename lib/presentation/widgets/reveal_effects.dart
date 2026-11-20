// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../main.dart';

class _Section extends StatelessWidget {
  const _Section({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, child: child);
}

class _ScrollRevealScope extends InheritedWidget {
  const _ScrollRevealScope({required this.controller, required super.child});

  final ScrollController controller;

  @override
  bool updateShouldNotify(_ScrollRevealScope oldWidget) =>
      oldWidget.controller != controller;
}

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );
  ScrollController? _scrollController;
  late double _viewportHeight;
  bool _started = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewportHeight = MediaQuery.sizeOf(context).height;
    final controller = context
        .dependOnInheritedWidgetOfExactType<_ScrollRevealScope>()
        ?.controller;
    if (!identical(controller, _scrollController)) {
      _scrollController?.removeListener(_startWhenVisible);
      _scrollController = controller;
      _scrollController?.addListener(_startWhenVisible);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWhenVisible());
  }

  void _startWhenVisible() {
    if (_started || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    if (bottom <= LayoutTokens.navbarHeight || top >= _viewportHeight) return;

    _started = true;
    _scrollController?.removeListener(_startWhenVisible);
    Future<void>.delayed(widget.delay, () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_startWhenVisible);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - animation.value)),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

class _HoverWrapper extends StatefulWidget {
  const _HoverWrapper({required this.child, this.lift = 6});
  final Widget child;
  final double lift;

  @override
  State<_HoverWrapper> createState() => _HoverWrapperState();
}

class _HoverWrapperState extends State<_HoverWrapper> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedScale(
      scale: hovered ? 1.02 : 1,
      duration: const Duration(milliseconds: 180),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, hovered ? -widget.lift : 0, 0),
        child: widget.child,
      ),
    ),
  );
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage(this.path, {required this.size, required this.onTap});
  final String path;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: path.isEmpty
        ? null
        : () => showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => _Lightbox(images: [path]),
          ),
    borderRadius: BorderRadius.circular(size / 2),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.sky, width: 8),
      ),
      child: ClipOval(
        child: path.isNotEmpty
            ? Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppTheme.sky),
              )
            : const ColoredBox(color: AppTheme.sky),
      ),
    ),
  );
}
