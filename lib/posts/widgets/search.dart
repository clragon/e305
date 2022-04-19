import 'package:e305/interface/widgets/search.dart';
import 'package:e305/posts/data/post.dart';
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

class SearchPage extends StatefulWidget {
  final PostController? controller;
  final String? title;
  final bool canSearch;
  final bool root;

  const SearchPage({
    this.controller,
    this.title,
    this.canSearch = true,
    this.root = false,
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

  void searchInRoute(String search) {
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

  @override
  void initState() {
    super.initState();
    initializeFavs();
    recommendations.database.addListener(initializeFavs);
  }

  @override
  void dispose() {
    recommendations.database.removeListener(initializeFavs);
    super.dispose();
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
      appBar: SearchableAppBar(
        canSearch: widget.canSearch,
        transparent: true,
        label: 'Tags',
        title: Text(widget.title ?? 'Search'),
        getSearch: () => controller.search.value,
        setSearch: (value) => controller.search.value = value,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = notZero(constraints.maxWidth / tileSize).round();

          return SmartRefresher(
            controller: controller.refreshController,
            onRefresh: () => controller.refresh(background: true),
            header: const ClassicHeader(
              refreshingIcon: OrbitLoadingIndicator(size: 40),
            ),
            child: PagedStaggeredGridView<int, Post>(
              key: Key(['posts', crossAxisCount].join('_')),
              physics: const BouncingScrollPhysics(),
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
                  onPressed: () {
                    SearchCallback? searchProvider;
                    if (widget.root) {
                      searchProvider = searchInRoute;
                    } else {
                      searchProvider = SearchProvider.of(context);
                    }
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => SearchProvider(
                          callback: searchProvider,
                          child: PostDetail(
                            post: controller.itemList![index],
                            hero: '${hero}_${item.id}',
                            controller: controller,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                firstPageProgressIndicatorBuilder: (context) => const Center(
                  child: OrbitLoadingIndicator(size: 100),
                ),
                newPageProgressIndicatorBuilder: (context) => const Padding(
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
