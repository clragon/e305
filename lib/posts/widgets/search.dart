import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/detail.dart';
import 'package:e305/posts/widgets/tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef SearchCallback = void Function(String search);

class SearchPage extends StatefulWidget {
  final SearchCallback? onSearch;
  final PostController? controller;
  final String? title;
  final bool static;

  SearchPage({
    this.controller,
    this.static = false,
    this.title,
    this.onSearch,
  }) : super(key: Key(controller?.search.value ?? UniqueKey().toString()));

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String hero = 'post_search_${UniqueKey()}';
  bool searching = false;
  int tileSize = 200;
  late PostController controller = widget.controller ?? PostController();
  ScrollController scrollController = ScrollController();
  TextEditingController textController = TextEditingController();

  double notZero(double value) => value < 1 ? 1 : value;

  PreferredSizeWidget appBar() {
    return ScrollToTop(
      controller: scrollController,
      child: SearchableAppBar(
        canSearch: !widget.static,
        transparent: true,
        label: 'Tags',
        title: widget.title ?? 'Search',
        getSearch: () => controller.search.value,
        setSearch: (value) => controller.search.value = value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          Widget gridBuilder(
            BuildContext context,
            IndexedWidgetBuilder itemBuilder,
            int itemCount,
            WidgetBuilder? appendixBuilder,
          ) {
            StaggeredTile? tileBuilder(int index) {
              if (index < (controller.itemList?.length ?? 0)) {
                Sample sample = controller.itemList![index].sample;
                double heightRatio = sample.height / sample.width;
                return StaggeredTile.count(1, heightRatio);
              }
              return null;
            }

            return MultiSliver(
              children: [
                SliverStaggeredGrid(
                  gridDelegate:
                      SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                    staggeredTileBuilder: tileBuilder,
                    crossAxisCount:
                        notZero(constraints.maxWidth / tileSize).round(),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    itemBuilder,
                    childCount: itemCount,
                  ),
                  addAutomaticKeepAlives: false,
                ),
                if (appendixBuilder != null)
                  SliverToBoxAdapter(
                    child: appendixBuilder(context),
                  ),
              ],
            );
          }

          return SmartRefresher(
            primary: false,
            scrollController: scrollController,
            controller: controller.refreshController,
            onRefresh: () => controller.refresh(background: true),
            header: ClassicHeader(
              refreshingIcon: OrbitLoadingIndicator(size: 40),
            ),
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                ),
                PagedSliverBuilder<int, Post>(
                  pagingController: controller,
                  builderDelegate: PagedChildBuilderDelegate<Post>(
                    itemBuilder: (context, item, index) => PostTile(
                      post: item,
                      hero: '${hero}_${item.id}',
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetail(
                            post: controller.itemList![index],
                            hero: '${hero}_${item.id}',
                            onSearch: widget.onSearch,
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
                  ),
                  completedListingBuilder: gridBuilder,
                  loadingListingBuilder: gridBuilder,
                  errorListingBuilder: gridBuilder,
                ),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
