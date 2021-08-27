import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/data/image.dart';
import 'package:e305/posts/widgets/image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:photo_view/photo_view.dart';

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
  final PostController controller;
  final PageController? pageController;
  final String? hero;

  const FullScreenGallery(
      {required this.controller, this.pageController, this.hero});

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController pageController =
      widget.pageController ?? PageController();
  late int page = pageController.initialPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(opacity: 0.3),
      body: PagedPageView(
        pagingController: widget.controller,
        pageController: pageController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, item, index) => PhotoView.customChild(
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.hero != null
                  ? '${widget.hero}_${item.id}'
                  : UniqueKey(),
              transitionOnUserGestures: true,
            ),
            childSize:
                Size(item.file.width.toDouble(), item.file.height.toDouble()),
            child: PhotoViewGestureDetectorScope(
              axis: Axis.horizontal,
              child: FullPostImage(
                post: item,
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: PulseLoadingIndicator(size: 100),
                ),
              ),
            ),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 6,
          ),
          firstPageProgressIndicatorBuilder: (context) => Center(
            child: OrbitLoadingIndicator(size: 100),
          ),
          newPageProgressIndicatorBuilder: (context) => Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: PulseLoadingIndicator(size: 60)),
          ),
        ),
        onPageChanged: (index) {
          setState(() {
            page = index;
          });
          if (widget.controller.itemList != null) {
            preloadImages(
                context: context,
                index: index,
                posts: widget.controller.itemList!,
                size: ImageSize.file);
          }
        },
      ),
    );
  }
}
