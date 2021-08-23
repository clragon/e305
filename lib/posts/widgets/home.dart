import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/image.dart';
import 'package:e305/posts/widgets/detail.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/posts/widgets/tile.dart';
import 'package:e305/profile/widgets/icon.dart';
import 'package:e305/settings/pages/host.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final SearchCallback? onSearch;

  const HomePage({this.onSearch});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HostMixin {
  RefreshController refreshController = RefreshController();
  PageController pageController = PageController();
  String hero = 'home_screen_${UniqueKey()}';
  List<Post>? posts;

  @override
  Future<void> onHostChange() async => reset();

  void updatePageController(double maxWidth) {
    pageController =
        PageController(viewportFraction: oneOrHigher(400 / maxWidth));
  }

  Future<void> reset() async {
    setState(() => this.posts = null);
    await refreshPosts();
  }

  Future<void> refreshPosts() async {
    List<Post> update = await client.posts('score:>=20', 1);
    setState(() => this.posts = update);
  }

  @override
  void initState() {
    super.initState();
    refreshPosts();
  }

  double oneOrHigher(double value) => (value > 1) ? 1 : value;

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Replacer(
        showChild: posts != null,
        child: SafeBuilder(
          showChild: posts != null,
          builder: (context) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                updatePageController(constraints.maxWidth);
                return PageView.builder(
                  onPageChanged: (index) => preloadImages(
                      context: context,
                      index: index,
                      posts: posts!,
                      size: ImageSize.sample),
                  controller: pageController,
                  itemCount: posts!.length,
                  itemBuilder: (context, index) => PostPageTile(
                    size: constraints.biggest,
                    post: posts![index],
                    hero: '${hero}_${posts![index].id}',
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => PostDetail(
                          post: posts![index],
                          hero: '${hero}_${posts![index].id}',
                          onSearch: widget.onSearch,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        secondChild: Center(
          child: OrbitLoadingIndicator(size: 100),
        ),
      );
    }

    return Scaffold(
      appBar: ScrollToTop(
        height: kToolbarHeight + 8,
        child: GestureDetector(
          onDoubleTap: () => pageController.animateToPage(0,
              curve: Curves.easeOut, duration: defaultAnimationDuration),
          child: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recommended'),
                SafeCrossFade(
                  showChild: true,
                  builder: (context) => RecommendationInfo(
                    hasRecommendations: false,
                  ),
                  secondChild: SizedBox.shrink(),
                ),
              ],
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
        controller: refreshController,
        onRefresh: () async {
          await refreshPosts();
          refreshController.refreshCompleted();
        },
        child: body(),
      ),
    );
  }
}

class RecommendationInfo extends StatelessWidget {
  final bool hasRecommendations;

  const RecommendationInfo({required this.hasRecommendations});

  @override
  Widget build(BuildContext context) {
    String title;
    String desc;
    String hint;

    if (hasRecommendations) {
      hint = 'Using Favorites';
      title = 'Recommendations with Favorites';
      desc =
          'Your recommendations are based on your most recent 600 favorites. '
          'Some of the most frequent tags are searched and the posts are sorted by correlation score. '
          'The highest scoring posts are then displayed here. ';
    } else {
      hint = 'Using Trending';
      title = 'Recommendations with Trending';
      desc =
          'For the favorite scoring algorithm to be able to recommend posts to you, '
          'you must be logged in and have to have at least 100 favorite posts. '
          'Until then, we display "score:>=20" posts here. '
          '\nGo favorite something!';
    }

    return InkWell(
      onTap: () {
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
            child: Icon(
              FontAwesomeIcons.infoCircle,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
