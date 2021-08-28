import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/data/image.dart';
import 'package:e305/posts/widgets/detail.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/posts/widgets/tile.dart';
import 'package:e305/profile/widgets/icon.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/tags/data/controller.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final SearchCallback? onSearch;

  const HomePage({this.onSearch});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RecommendationStatus recommendationStatus = RecommendationStatus.loading;

  RecommendationController controller =
      RecommendationController(search: 'score:>=20', sort: true);
  PageController pageController = PageController();
  String hero = 'home_screen_${UniqueKey()}';

  Future<bool> hasLogin = client.hasLogin;

  void onSearch(String search) {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
    return widget.onSearch?.call(search);
  }

  void updateLogin() {
    setState(() {
      hasLogin = client.hasLogin;
    });
  }

  void updatePageController(double maxWidth) {
    double oneOrHigher(double value) => (value > 1) ? 1 : value;
    pageController = PageController(
      viewportFraction: oneOrHigher(400 / maxWidth),
    );
  }

  Future<void> initializeFavs() async {
    List<SlimPost>? favs = await favoriteDatabase.getFavorites();
    setState(() {
      if (favs == null) {
        recommendationStatus = RecommendationStatus.anonymous;
      } else if (favs.length < 200) {
        recommendationStatus = RecommendationStatus.insufficient;
      } else {
        recommendationStatus = RecommendationStatus.functional;
      }
      controller.favs.value = favs;
      controller.search.value = 'order:random';
    });
  }

  @override
  void initState() {
    super.initState();
    settings.credentials.addListener(updateLogin);
    initializeFavs();
  }

  @override
  void dispose() {
    settings.credentials.removeListener(updateLogin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            updatePageController(constraints.maxWidth);
            return PagedPageView(
              pageController: pageController,
              pagingController: controller,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, Post item, index) => PostPageTile(
                  controller: controller,
                  post: controller.itemList![index],
                  hero: '${hero}_${controller.itemList![index].id}',
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => PostDetail(
                        post: controller.itemList![index],
                        hero: '${hero}_${controller.itemList![index].id}',
                        onSearch: onSearch,
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
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'no posts',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
              onPageChanged: (index) => preloadImages(
                context: context,
                index: index,
                posts: controller.itemList!,
                size: ImageSize.sample,
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 8),
        child: LayoutBuilder(
          builder: (context, constraints) => AppBar(
            title: GestureDetector(
              onDoubleTap: () => pageController.animateToPage(0,
                  curve: Curves.easeOut, duration: defaultAnimationDuration),
              child: Container(
                color: Colors.transparent,
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommended'),
                    FutureBuilder<bool>(
                      future: hasLogin,
                      builder: (context, snapshot) {
                        return SafeCrossFade(
                          showChild: true,
                          builder: (context) => RecommendationInfo(
                            status: recommendationStatus,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: ProfileButton(),
              ),
            ],
          ),
        ),
      ),
      body: SmartRefresher(
        controller: controller.refreshController,
        onRefresh: () {
          controller.refresh(background: true);
          pageController.animateToPage(0,
              curve: Curves.easeOut, duration: defaultAnimationDuration);
        },
        child: body(),
      ),
    );
  }
}

enum RecommendationStatus { loading, anonymous, insufficient, functional }

class RecommendationInfo extends StatelessWidget {
  final RecommendationStatus status;

  const RecommendationInfo({required this.status});

  @override
  Widget build(BuildContext context) {
    String title;
    String desc;
    String hint;

    switch (status) {
      case RecommendationStatus.loading:
        hint = 'Fetching recommendations';
        title = 'We are loading recommendations for you';
        desc = 'An explanation will be displayed here shortly!';
        break;
      case RecommendationStatus.anonymous:
        hint = 'Using Trending';
        title = 'Recommendations with Trending';
        desc =
            'For the favorite scoring algorithm to be able to recommend posts to you, '
            'you must be logged in and have to have at least 200 favorite posts. '
            'Until then, we display trending posts here. '
            '\nPlease log in to use this functionality!';
        break;
      case RecommendationStatus.insufficient:
        hint = 'Using Trending';
        title = 'Recommendations with Trending';
        desc =
            'For the favorite scoring algorithm to be able to recommend posts to you, '
            'you must have to have at least 200 favorite posts. '
            'Until then, we display trending posts here. '
            '\nGo favorite something!';
        break;
      case RecommendationStatus.functional:
        hint = 'Using Favorites';
        title = 'Recommendations with Favorites';
        desc =
            'Your recommendations are based on your most recent up to 1200 favorites. '
            'Random posts from the site are fetched and sorted by correlation score. '
            '\nRefresh to get new posts. ';
        break;
    }

    return InkWell(
      onTap: () {
        if (status != RecommendationStatus.loading) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(desc),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).maybePop,
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              hint,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                .copyWith(right: 0),
            child: status == RecommendationStatus.loading
                ? PulseLoadingIndicator(size: 14)
                : Icon(
                    FontAwesomeIcons.infoCircle,
                    size: 16,
                  ),
          ),
        ],
      ),
    );
  }
}
