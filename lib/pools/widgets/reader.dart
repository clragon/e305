import 'package:e305/client/models/pool.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/pools/data/controller.dart';
import 'package:e305/pools/widgets/tile.dart';
import 'package:e305/posts/widgets/fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PoolReader extends StatefulWidget {
  final Pool pool;

  const PoolReader({required this.pool});

  @override
  _PoolReaderState createState() => _PoolReaderState();
}

class _PoolReaderState extends State<PoolReader> {
  String hero = 'pool_reader_${UniqueKey()}';
  ScrollController scrollController = ScrollController();
  late PoolPostController controller = PoolPostController(pool: widget.pool);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: ScrollToTop(
          controller: scrollController,
          child: AnimatedBuilder(
            animation: scrollController,
            builder: (context, child) => AnimatedOpacity(
              opacity: scrollController.hasClients
                  ? scrollController.offset <= 0
                      ? 1
                      : 0.3
                  : 1,
              duration: defaultAnimationDuration,
              child: TransparentAppBar(
                title: Text(widget.pool.name.replaceAll('_', ' ')),
              ),
            ),
          ),
        ),
        body: PagedListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          scrollController: scrollController,
          primary: false,
          physics: BouncingScrollPhysics(),
          pagingController: controller,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, item, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: PoolReaderTile(
                post: item,
                hero: '${hero}_${item.id}',
                width: constraints.maxWidth,
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: Navigator.of(context).maybePop,
                      child: FullScreenGallery(
                        initialPage: index,
                        posts: controller.itemList!,
                        hero: hero,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            firstPageProgressIndicatorBuilder: (context) => Center(
              child: OrbitLoadingIndicator(size: 100),
            ),
            newPageProgressIndicatorBuilder: (context) => Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: PulseLoadingIndicator(size: 60)),
            ),
            noItemsFoundIndicatorBuilder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(FontAwesomeIcons.times),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('no posts'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
