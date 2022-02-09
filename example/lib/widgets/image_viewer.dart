import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  ImageViewer(this.files, {this.initialIndex, Key? key}) : super(key: key);

  final List<String> files;
  final int? initialIndex;

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex ?? 0;
    _controller = PageController(initialPage: currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Stack(
        children: [
          Container(
            child: PhotoViewGallery.builder(
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              itemCount: widget.files.length,
              scrollPhysics: const ClampingScrollPhysics(),
              builder: (BuildContext context, int i) {
                return PhotoViewGalleryPageOptions(
                  minScale: .3,
                  imageProvider: NetworkImage(widget.files[i]),
                  initialScale: PhotoViewComputedScale.contained * 1,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.files[i]),
                );
              },
              loadingBuilder: (context, event) => CircularProgressIndicator(),
              pageController: _controller,
              onPageChanged: (i) => setState(() => currentIndex = i),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.redAccent, size: 28),
              onPressed: () => Get.back(),
            ),
          ),
          if (currentIndex != 0)
            Positioned(
              bottom: (MediaQuery.of(context).size.height / 2) - 28,
              child: IconButton(
                icon: Icon(Icons.arrow_left_rounded, color: Colors.white, size: 32),
                onPressed: () => _controller.previousPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                ),
              ),
            ),
          if (currentIndex != widget.files.length - 1)
            Positioned(
              bottom: (MediaQuery.of(context).size.height / 2) - 28,
              right: 18,
              child: IconButton(
                icon: Icon(Icons.arrow_right_rounded, color: Colors.white, size: 32),
                onPressed: () => _controller.nextPage(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
