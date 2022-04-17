import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/detail.dart';
import 'package:e305/posts/widgets/tile.dart';
import 'package:e305/recommendations/data/updater.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  late PostController controller =
      widget.controller ?? RecommendationController();
  ScrollController scrollController = ScrollController();
  TextEditingController textController = TextEditingController();

  Future<void> initializeFavs() async {
    if (controller is RecommendationController) {
      (controller as RecommendationController).favs.value = null;
      List<SlimPost>? favs = await recommendations.getFavorites();
      if (favs != null && favs.length > recommendations.required) {
        (controller as RecommendationController).favs.value = favs;
      }
    }
  }

  double notZero(double value) => value < 1 ? 1 : value;

  void defaultOnSearch(String search) async {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchPage(
          controller: RecommendationController(search: search),
        ),
      ),
    );
  }

  void ensureIsFirst() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void initState() {
    super.initState();
    initializeFavs();
    recommendations.database.addListener(initializeFavs);
    controller.search.addListener(ensureIsFirst);
  }

  @override
  void dispose() {
    recommendations.database.removeListener(initializeFavs);
    controller.search.removeListener(ensureIsFirst);
    super.dispose();
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

  StaggeredTile? tileBuilder(int index) {
    if (index < (controller.itemList?.length ?? 0)) {
      Sample sample = controller.itemList![index].sample;
      double heightRatio = sample.height / sample.width;
      return StaggeredTile.count(1, heightRatio);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = notZero(constraints.maxWidth / tileSize).round();

          return SmartRefresher(
            primary: false,
            scrollController: scrollController,
            controller: controller.refreshController,
            onRefresh: () => controller.refresh(background: true),
            header: ClassicHeader(
              refreshingIcon: OrbitLoadingIndicator(size: 40),
            ),
            child: PagedStaggeredGridView<int, Post>(
              key: Key(['posts', crossAxisCount].join('_')),
              physics: BouncingScrollPhysics(),
              addAutomaticKeepAlives: false,
              pagingController: controller,
              gridDelegateBuilder: (childCount) =>
                  SliverStaggeredGridDelegateWithFixedCrossAxisCount(
                staggeredTileBuilder: tileBuilder,
                crossAxisCount: crossAxisCount,
              ),
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, item, index) => PostTile(
                  post: item,
                  hero: '${hero}_${item.id}',
                  controller: controller,
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => PostDetail(
                        post: controller.itemList![index],
                        hero: '${hero}_${item.id}',
                        onSearch: widget.onSearch ?? defaultOnSearch,
                        controller: controller,
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
            ),
          );
        },
      ),
    );
  }
}
