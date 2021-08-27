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
  });

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

  void defaultOnSearch(String search) async {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchPage(
          controller: PostController(search: search),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return ScrollToTopAppBar(
      controller: scrollController,
      builder: (context, gesture) => SearchableAppBar(
        canSearch: !widget.static,
        transparent: true,
        label: 'Tags',
        title: gesture(context, Text(widget.title ?? 'Search')),
        getSearch: () => controller.search.value,
        setSearch: (value) => controller.search.value = value,
      ),
    );
  }

  void ensureIsFirst() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    controller.search.addListener(ensureIsFirst);
  }

  @override
  void dispose() {
    controller.search.removeListener(ensureIsFirst);
    super.dispose();
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

            int crossAxiscount =
                notZero(constraints.maxWidth / tileSize).round();

            return MultiSliver(
              children: [
                SliverStaggeredGrid(
                  key: Key(crossAxiscount.toString()),
                  gridDelegate:
                      SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                    staggeredTileBuilder: tileBuilder,
                    crossAxisCount: crossAxiscount,
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
                  sliver: PagedSliverBuilder<int, Post>(
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
                              onSearch: widget.onSearch ?? defaultOnSearch,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
