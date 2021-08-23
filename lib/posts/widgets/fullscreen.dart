import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/image.dart';
import 'package:e305/posts/widgets/image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenPost extends StatelessWidget {
  final Post post;
  final String? hero;

  const FullScreenPost({required this.post, this.hero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(opacity: 0.3),
      body: PhotoView.customChild(
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        heroAttributes: PhotoViewHeroAttributes(
          tag: hero ?? UniqueKey(),
        ),
        childSize:
            Size(post.file.width.toDouble(), post.file.height.toDouble()),
        child: FullPostImage(post: post),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final int initialPage;
  final List<Post> posts;
  final String? hero;

  const FullScreenGallery(
      {required this.posts, this.hero, this.initialPage = 0});

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(opacity: 0.3),
      body: PhotoViewGallery.builder(
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        scrollDirection: Axis.horizontal,
        pageController: controller,
        itemCount: widget.posts.length,
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
          heroAttributes: PhotoViewHeroAttributes(
            tag: widget.hero != null
                ? '${widget.hero}_${widget.posts[index].id}'
                : UniqueKey(),
          ),
          childSize: Size(widget.posts[index].file.width.toDouble(),
              widget.posts[index].file.height.toDouble()),
          child: FullPostImage(
            post: widget.posts[index],
            progressIndicatorBuilder: (context, url, progress) => Center(
              child: PulseLoadingIndicator(size: 100),
            ),
          ),
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 6,
        ),
        onPageChanged: (index) {
          preloadImages(
              context: context,
              index: index,
              posts: widget.posts,
              size: ImageSize.file);
        },
      ),
    );
  }
}
