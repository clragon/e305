import 'dart:math';

import 'package:e305/client/models/post.dart';
import 'package:e305/tags/data/post.dart';

import 'count.dart';

class ScoredPost {
  final int id;
  final Map<String, List<String>> tags;
  final double score;

  ScoredPost({
    required this.id,
    required this.tags,
    required this.score,
  });
}

class ScoredTag {
  final String category;
  final String tag;
  final int count;
  final double score;
  final double weigth;

  ScoredTag({
    required this.weigth,
    required this.category,
    required this.tag,
    required this.count,
    required this.score,
  });
}

Map<String, double> defaultWeights = {
  'general': 0.5,
  'species': 1,
  'character': 5,
  'artist': 6,
  'meta': 0.5,
};

List<ScoredTag> createScoreTable(List<CountedTag> counts,
    {Map<String, double>? weigths, double threshold = 0.1}) {
  int bottom = 0;
  int top = 0;

  for (CountedTag tag in counts) {
    bottom = min(tag.count, bottom);
    top = max(tag.count, top);
  }

  int range = top - bottom;
  List<ScoredTag> scores = [];

  double curve(double x, [double power = 3]) {
    return (1 - pow(1 - x, power)).toDouble();
  }

  for (CountedTag tag in counts) {
    double score = (tag.count - bottom) / range;
    score = curve(score);
    score = score * ((weigths ?? defaultWeights)[tag.category] ?? 1);
    scores.add(ScoredTag(
      tag: tag.tag,
      category: tag.category,
      count: tag.count,
      score: score,
      weigth: 1,
    ));
  }

  scores.removeWhere((element) => element.score < threshold);
  scores.sort((a, b) => b.score.compareTo(a.score));

  return scores;
}

double scoreItem<T>(List<ScoredTag> scores, T item,
    List<String> Function(T element, String category) getCategory,
    {int? cap}) {
  List<double> values = [];
  for (String category in categories.keys) {
    for (String tag in getCategory(item, category)) {
      try {
        ScoredTag scored = scores.firstWhere(
          (element) => element.tag == tag,
        );
        values.add((scored.score * scored.weigth));
      } on StateError {
        continue;
      }
    }
  }

  values.sort((a, b) => b.compareTo(a));
  if (cap != null) {
    values = values.take(cap).toList();
  }

  double value =
      values.fold(0, (previousValue, element) => previousValue + element);

  return value;
}

ScoredPost scoreSlim(List<ScoredTag> scores, SlimPost post, {int? cap}) {
  double value = scoreItem<SlimPost>(
    scores,
    post,
    (element, category) => element.tags[category]!,
    cap: cap,
  );

  return ScoredPost(
    id: post.id,
    tags: post.tags,
    score: value,
  );
}

double scorePost(List<ScoredTag> scores, Post post, {int? cap}) {
  return scoreItem<Post>(
      scores, post, (element, category) => element.tags[category]!,
      cap: cap);
}
