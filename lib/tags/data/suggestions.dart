import 'package:e305/client/models/post.dart';
import 'package:e305/tags/data/post.dart';
import 'package:e305/tags/data/score.dart';

import 'count.dart';

List<CountedTag> getRecommendedTags(List<SlimPost> posts, {int? threshold}) {
  int limit = threshold ?? 5;
  List<String> common = [
    'anthro',
    'fur',
    'conditional_dnp',
  ];

  List<CountedTag> counted = countTagsBySlims(posts);
  counted.sort((a, b) => b.count.compareTo(a.count));
  counted.removeWhere((element) => limit > element.count);
  counted.removeWhere((element) => common.contains(element.tag));
  return counted;
}

Future<Map<Post, double>> ratePosts(List<SlimPost> favs, List<Post> posts,
    {Map<String, double>? weights}) async {
  List<CountedTag> counts = countTagsBySlims(favs);
  List<ScoredTag> scores = createScoreTable(counts, weigths: weights);
  List<MapEntry<Post, List<ScoredTag>>> uncapped = [];

  for (Post post in posts) {
    List<ScoredTag> scored = scorePost(scores, post);
    uncapped.add(MapEntry(post, scored));
  }

  int? median;
  List<int> tagCounts = uncapped.map((e) => e.value.length).toList();
  tagCounts.sort((a, b) => b.compareTo(a));
  if (tagCounts.isNotEmpty) {
    median = tagCounts[(tagCounts.length * 0.75).floor()];
  }

  List<MapEntry<Post, double>> unsorted = [];
  List<MapEntry<Post, List<ScoredTag>>> capped = [];

  if (median != null) {
    for (MapEntry<Post, List<ScoredTag>> element in uncapped) {
      capped.add(MapEntry(element.key, element.value.take(median).toList()));
    }
  } else {
    capped = uncapped;
  }

  for (MapEntry<Post, List<ScoredTag>> element in capped) {
    unsorted.add(
      MapEntry(
        element.key,
        element.value.fold(
          0,
          (previousValue, element) =>
              previousValue + (element.score * element.weigth),
        ),
      ),
    );
  }

  Map<Post, List<ScoredTag>> tagged = {};
  tagged.addEntries(capped);
  Map<Post, double> scored = {};
  scored.addEntries(unsorted);

  for (Post post in posts) {
    post.recommendationValue = scored[post];
    post.recommendedTags = tagged[post];
  }

  return scored;
}
