/// หน้าที่หลัก: แสดงแกลเลอรีภาพแบบ Lightbox พร้อมซูมและเลื่อนภาพ
part of '../portfolio_ui.dart';

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.images, this.initialIndex = 0});
  final List<String> images;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final controller = PageController(initialPage: widget.initialIndex);
  late var index = widget.initialIndex;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.zero,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xE0000000)),
          PageView.builder(
            controller: controller,
            itemCount: widget.images.length,
            onPageChanged: (value) => setState(() => index = value),
            itemBuilder: (context, i) => InteractiveViewer(
              minScale: .5,
              maxScale: 5,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Image.asset(widget.images[i], fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton.filled(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          if (widget.images.length > 1) ...[
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: IconButton.filledTonal(
                onPressed: () => controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                icon: const Icon(Icons.chevron_left),
              ),
            ),
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: IconButton.filledTonal(
                onPressed: () => controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                icon: const Icon(Icons.chevron_right),
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
  );
}
