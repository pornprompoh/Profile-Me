/// หน้าที่หลัก: แสดงแกลเลอรีภาพแบบ Lightbox พร้อมซูมและเลื่อนภาพ
part of '../portfolio_ui.dart';

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.images, this.initialIndex = 0});
  final List<String> images;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox>
    with SingleTickerProviderStateMixin {
  late final controller = PageController(initialPage: widget.initialIndex);
  late final AnimationController zoomAnimationController;
  late var index = widget.initialIndex;
  final isZoomed = ValueNotifier<bool>(false);
  final controllers = <int, TransformationController>{};

  @override
  void initState() {
    super.initState();
    zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    zoomAnimationController.dispose();
    controller.dispose();
    isZoomed.dispose();
    for (final item in controllers.values) {
      item.dispose();
    }
    super.dispose();
  }

  TransformationController _controllerFor(int page) =>
      controllers.putIfAbsent(page, () {
        final controller = TransformationController();
        controller.addListener(() => _syncZoomed(controller));
        return controller;
      });

  void _syncZoomed(TransformationController controller) {
    final scale = controller.value.getMaxScaleOnAxis();
    isZoomed.value = scale > 1.01;
  }

  void _resetZoom({bool animate = true}) {
    final controller = controllers[index];
    if (controller == null) return;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (!animate || disableAnimations) {
      zoomAnimationController.stop();
      controller.value = Matrix4.identity();
      isZoomed.value = false;
      return;
    }
    zoomAnimationController.stop();
    final begin = controller.value.clone();
    final animation = Matrix4Tween(begin: begin, end: Matrix4.identity())
        .animate(
          CurvedAnimation(
            parent: zoomAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
    void listener() => controller.value = animation.value;
    animation.addListener(listener);
    zoomAnimationController.forward(from: 0).whenComplete(() {
      animation.removeListener(listener);
      controller.value = Matrix4.identity();
      isZoomed.value = false;
    });
  }

  void _toggleDoubleTap(int page, Offset localPosition) {
    final controller = _controllerFor(page);
    final scale = controller.value.getMaxScaleOnAxis();
    if (scale > 1.01) {
      _resetZoom();
      return;
    }
    const targetScale = 2.3;
    final target = Matrix4.identity()
      ..translateByDouble(
        (1 - targetScale) * localPosition.dx,
        (1 - targetScale) * localPosition.dy,
        0,
        1,
      )
      ..scaleByDouble(targetScale, targetScale, 1, 1);
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = target;
      isZoomed.value = true;
      return;
    }
    zoomAnimationController.stop();
    final begin = controller.value.clone();
    final animation = Matrix4Tween(begin: begin, end: target).animate(
      CurvedAnimation(
        parent: zoomAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    void listener() => controller.value = animation.value;
    animation.addListener(listener);
    zoomAnimationController.forward(from: 0).whenComplete(() {
      animation.removeListener(listener);
      controller.value = target;
      isZoomed.value = true;
    });
  }

  void _resetAllZoom() {
    for (final item in controllers.values) {
      item.value = Matrix4.identity();
    }
    isZoomed.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < LayoutTokens.mobileBreakpoint;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(context),
        },
        child: Focus(
          autofocus: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isZoomed.value) {
                _resetZoom();
              } else {
                Navigator.pop(context);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xE0000000)),
                ValueListenableBuilder<bool>(
                  valueListenable: isZoomed,
                  builder: (context, zoomed, _) => PageView.builder(
                    controller: controller,
                    physics: zoomed
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    itemCount: widget.images.length,
                    onPageChanged: (value) {
                      _resetAllZoom();
                      setState(() => index = value);
                    },
                    itemBuilder: (context, i) {
                      final transformation = _controllerFor(i);
                      Offset? doubleTapPosition;
                      return Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent &&
                              event.kind == PointerDeviceKind.mouse) {
                            // เมาส์ใช้แพนภาพไม่ได้และไม่ควรซูมภาพด้วยล้อ
                          }
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          onDoubleTapDown: (details) =>
                              doubleTapPosition = details.localPosition,
                          onDoubleTap: () => _toggleDoubleTap(
                            i,
                            doubleTapPosition ?? Offset.zero,
                          ),
                          child: InteractiveViewer(
                            transformationController: transformation,
                            minScale: 1,
                            maxScale: 4,
                            trackpadScrollCausesScale: false,
                            panEnabled: true,
                            scaleEnabled: true,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Image.asset(
                                  widget.images[i],
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) =>
                                      const ColoredBox(color: AppTheme.sky),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isZoomed,
                  builder: (context, zoomed, _) => IgnorePointer(
                    ignoring: zoomed,
                    child: AnimatedOpacity(
                      opacity: zoomed ? 0 : 1,
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 160),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            top: 24,
                            right: 24,
                            child: IconButton.filled(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                          if (!isMobile && widget.images.length > 1) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: IconButton.filledTonal(
                                    onPressed: () => controller.previousPage(
                                      duration: disableAnimations
                                          ? Duration.zero
                                          : const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: IconButton.filledTonal(
                                    onPressed: () => controller.nextPage(
                                      duration: disableAnimations
                                          ? Duration.zero
                                          : const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                '${index + 1} / ${widget.images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
