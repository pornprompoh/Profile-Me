// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../main.dart';

class _ProjectModal extends StatefulWidget {
  const _ProjectModal({
    required this.project,
    required this.links,
    required this.locale,
  });
  final Project project;
  final Links links;
  final AppLocale locale;

  @override
  State<_ProjectModal> createState() => _ProjectModalState();
}

class _ProjectModalState extends State<_ProjectModal> {
  final pageController = PageController();
  var index = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.project.images;
    final projectLinks = widget.links.projectLinks
        .where((link) => link.projectId == widget.project.id)
        .toList();
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LayoutTokens.modalRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.locale == AppLocale.th
                              ? widget.project.title.th
                              : widget.project.title.en,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: PageView.builder(
                                  controller: pageController,
                                  itemCount: images.length,
                                  onPageChanged: (value) =>
                                      setState(() => index = value),
                                  itemBuilder: (context, i) => InkWell(
                                    onTap: () => showDialog<void>(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (_) => _Lightbox(
                                        images: images,
                                        initialIndex: i,
                                      ),
                                    ),
                                    child: Image.asset(
                                      images[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const ColoredBox(color: AppTheme.sky),
                                    ),
                                  ),
                                ),
                              ),
                              if (MediaQuery.sizeOf(context).width > 700)
                                Positioned(
                                  left: 8,
                                  child: IconButton.filledTonal(
                                    onPressed: () =>
                                        pageController.previousPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        ),
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                ),
                              if (MediaQuery.sizeOf(context).width > 700)
                                Positioned(
                                  right: 8,
                                  child: IconButton.filledTonal(
                                    onPressed: () => pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    ),
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ),
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${index + 1} / ${images.length}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        widget.locale == AppLocale.th
                            ? widget.project.description.th
                            : widget.project.description.en,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.locale == AppLocale.th
                            ? 'จุดเด่น'
                            : 'Highlights',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final highlight in widget.project.highlights)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(
                            widget.locale == AppLocale.th
                                ? highlight.th
                                : highlight.en,
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in widget.project.tags)
                            Chip(label: Text(tag)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final link in projectLinks)
                            ProjectLinkButton(
                              link: link,
                              locale: widget.locale,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          GestureDetector(
            onTap: () {},
            child: PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => index = value),
              itemBuilder: (context, i) => InteractiveViewer(
                minScale: .5,
                maxScale: 5,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(widget.images[i], fit: BoxFit.contain),
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

