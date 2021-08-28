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
    {bool sort = true, Map<String, double>? weights}) async {
  List<CountedTag> counts = countTagsBySlims(favs);
  List<ScoredTag> scores = createScoreTable(counts, weigths: weights);
  List<MapEntry<Post, double>> unsorted = [];

  List<int> tagCounts = posts
      .map((e) => e.tags.values.fold<int>(
          0, (previousValue, element) => previousValue + element.length))
      .toList();
  tagCounts.sort();

  int? median;
  if (tagCounts.isNotEmpty) {
    median = tagCounts[(tagCounts.length * 0.75).floor()];
  }

  for (Post post in posts) {
    double value = scorePost(scores, post, cap: median);
    unsorted.add(MapEntry(post, value));
  }
  if (sort) {
    unsorted.sort((a, b) => b.value.compareTo(a.value));
  }

  Map<Post, double> scored = {};
  scored.addEntries(unsorted);

  return scored;
}
