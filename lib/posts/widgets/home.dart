import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/search.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/data/image.dart';
import 'package:e305/posts/widgets/detail.dart';
import 'package:e305/posts/widgets/hero.dart';
import 'package:e305/posts/widgets/tile.dart';
import 'package:e305/profile/widgets/icon.dart';
import 'package:e305/recommendations/data/updater.dart';
import 'package:e305/recommendations/widgets/recommendations.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RecommendationController controller =
      RecommendationController(search: 'score:>=20', sort: true);
  PageController pageController = PageController();
  String hero = 'home_screen_${UniqueKey()}';

  double? _lastMaxWidth;
  void updatePageController(double maxWidth) {
    if (maxWidth == _lastMaxWidth) {
      return;
    }
    _lastMaxWidth = maxWidth;
    double oneOrHigher(double value) => (value > 1) ? 1 : value;
    pageController = PageController(
      viewportFraction: oneOrHigher(400 / maxWidth),
    );
  }

  Future<void> updateTags() async {
    controller.search.value = settings.homeTags.value;
  }

  Future<void> initializeFavs() async {
    controller.favs.value = null;
    List<SlimPost>? favs = await recommendations.getFavorites();
    if (favs != null && favs.length > recommendations.required) {
      controller.favs.value = favs;
      await updateTags();
    } else {
      controller.search.value = 'score:>=20';
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFavs();
    recommendations.database.addListener(initializeFavs);
    settings.homeTags.addListener(updateTags);
  }

  @override
  void dispose() {
    recommendations.removeListener(initializeFavs);
    settings.homeTags.removeListener(updateTags);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: pageController,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 8,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              IgnorePointer(child: Text('Recommended')),
              RecommendationInfo(),
            ],
          ),
          flexibleSpace: const ScrollToTop(),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: ProfileButton(),
            ),
          ],
        ),
        body: SmartRefresher(
          controller: controller.refreshController,
          onRefresh: () async {
            await controller.refresh(background: true);
            pageController.animateToPage(0,
                curve: Curves.easeOut, duration: defaultAnimationDuration);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                updatePageController(constraints.maxWidth);
                return HeroProvider(
                  builder: (id) => 'home_$hashCode post#$id',
                  child: PagedPageView(
                    pageController: pageController,
                    pagingController: controller,
                    builderDelegate: PagedChildBuilderDelegate<Post>(
                      itemBuilder: (context, item, index) => PostPageTile(
                        controller: controller,
                        post: controller.itemList![index],
                        onTap: () {
                          SearchCallback? searchProvider =
                              SearchProvider.of(context);
                          HeroBuilder? heroBuilder = HeroProvider.of(context);
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => SearchProvider(
                                callback: searchProvider,
                                child: HeroProvider(
                                  builder: heroBuilder,
                                  child: PostDetail(
                                    post: controller.itemList![index],
                                    controller: controller,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Center(
                        child: OrbitLoadingIndicator(size: 100),
                      ),
                      newPageProgressIndicatorBuilder: (context) =>
                          const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: PulseLoadingIndicator(size: 60)),
                      ),
                      noItemsFoundIndicatorBuilder: (context) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                      reach: 5,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
