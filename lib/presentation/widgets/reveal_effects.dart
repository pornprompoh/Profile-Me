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
  const _ScrollRevealScope({
    required this.controller,
    required this.metricsRevision,
    required super.child,
  });

  final ScrollController controller;
  final ValueNotifier<int> metricsRevision;

  @override
  bool updateShouldNotify(_ScrollRevealScope oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.metricsRevision != metricsRevision;
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
  ValueNotifier<int>? _metricsRevision;
  Timer? _settleTimer;
  Timer? _initialGuardTimer;
  late double _viewportHeight;
  bool _started = false;
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    // ตรวจซ้ำหลัง layout รอบแรก เผื่อ ScrollMetrics พร้อมช้ากว่า frame แรก
    _initialGuardTimer = Timer(
      const Duration(milliseconds: 700),
      _scheduleVisibilityCheck,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewportHeight = MediaQuery.sizeOf(context).height;
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ScrollRevealScope>();
    final controller = scope?.controller;
    if (!identical(controller, _scrollController)) {
      _scrollController?.removeListener(_startWhenVisible);
      _scrollController?.removeListener(_onScrollChanged);
      _scrollController = controller;
      _scrollController?.addListener(_onScrollChanged);
    }
    if (!identical(scope?.metricsRevision, _metricsRevision)) {
      _metricsRevision?.removeListener(_scheduleVisibilityCheck);
      _metricsRevision = scope?.metricsRevision;
      _metricsRevision?.addListener(_scheduleVisibilityCheck);
    }
    _scheduleVisibilityCheck();
  }

  void _onScrollChanged() {
    _scheduleVisibilityCheck();
    _settleTimer?.cancel();
    _settleTimer = Timer(
      const Duration(milliseconds: 180),
      _scheduleVisibilityCheck,
    );
  }

  void _scheduleVisibilityCheck() {
    if (_started || !mounted || _checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      _startWhenVisible();
    });
  }

  void _startWhenVisible() {
    if (_started || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    final intersectsViewport =
        bottom > LayoutTokens.navbarHeight && top < _viewportHeight;
    final alreadyPassed = bottom <= LayoutTokens.navbarHeight;
    // เมื่อข้ามส่วนนี้ไปแล้วหรืออยู่ท้ายหน้า ให้เริ่มแอนิเมชันแทนการค้างโปร่งใส
    final atPageEnd =
        _scrollController?.hasClients == true &&
        _scrollController!.position.pixels >=
            _scrollController!.position.maxScrollExtent - 1 &&
        top < _viewportHeight;
    if (!intersectsViewport && !alreadyPassed && !atPageEnd) return;

    _started = true;
    _initialGuardTimer?.cancel();
    _settleTimer?.cancel();
    _scrollController?.removeListener(_onScrollChanged);
    _metricsRevision?.removeListener(_scheduleVisibilityCheck);
    Future<void>.delayed(widget.delay, () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    _initialGuardTimer?.cancel();
    _settleTimer?.cancel();
    _scrollController?.removeListener(_onScrollChanged);
    _metricsRevision?.removeListener(_scheduleVisibilityCheck);
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
