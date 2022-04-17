import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/recommendations/data/updater.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum RecommendationStatus { loading, anonymous, insufficient, functional }

class RecommendationInfo extends StatefulWidget {
  const RecommendationInfo();

  @override
  _RecommendationInfoState createState() => _RecommendationInfoState();
}

class _RecommendationInfoState extends State<RecommendationInfo> {
  RecommendationStatus status = RecommendationStatus.loading;

  Future<void> updateStatus() async {
    setState(() {
      status = RecommendationStatus.loading;
    });
    List<SlimPost>? favs = await recommendations.getFavorites();
    setState(() {
      if (favs == null) {
        status = RecommendationStatus.anonymous;
      } else if (favs.length < recommendations.required) {
        status = RecommendationStatus.insufficient;
      } else {
        status = RecommendationStatus.functional;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    recommendations.database.addListener(updateStatus);
    updateStatus();
  }

  @override
  void dispose() {
    recommendations.database.removeListener(updateStatus);
    super.dispose();
  }

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
            'you must be logged in and have to have at least ${recommendations.required} favorite posts. '
            'Until then, we display trending posts here. '
            '\nPlease log in to use this functionality!';
        break;
      case RecommendationStatus.insufficient:
        hint = 'Using Trending';
        title = 'Recommendations with Trending';
        desc =
            'For the favorite scoring algorithm to be able to recommend posts to you, '
            'you must have to have at least ${recommendations.required} favorite posts. '
            'Until then, we display trending posts here. '
            '\nGo favorite something!';
        break;
      case RecommendationStatus.functional:
        hint = 'Using Favorites';
        title = 'Recommendations with Favorites';
        desc =
            'Your recommendations are based on your most recent up to ${recommendations.limit} favorites. '
            'Random posts from the site are fetched and sorted by correlation score. '
            '\nRefresh to get new posts. ';
        break;
    }

    return InkWell(
      onTap: status != RecommendationStatus.loading
          ? () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(title),
                  content: Text(desc),
                  actions: [
                    TextButton(
                      onPressed: Navigator.of(context).maybePop,
                      child: const Text('OK'),
                    ),
                  ],
                ),
              )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              hint,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: recommendations.progress,
            builder: (context, value, child) => CrossFade(
              showChild: status == RecommendationStatus.loading &&
                  recommendations.progress.value > 0,
              child: TweenAnimationBuilder(
                tween: IntTween(begin: 0, end: recommendations.progress.value),
                duration: const Duration(milliseconds: 500),
                builder: (context, int value, child) => Text(
                  ' $value/${recommendations.limit}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                .copyWith(right: 0),
            child: status == RecommendationStatus.loading
                ? const PulseLoadingIndicator(size: 14)
                : const Icon(
                    FontAwesomeIcons.infoCircle,
                    size: 16,
                  ),
          ),
        ],
      ),
    );
  }
}
