import 'package:e305/tags/data/post.dart';

class CountedTag {
  final String category;
  final String tag;
  final int count;

  CountedTag({
    required this.category,
    required this.tag,
    required this.count,
  });
}

Map<String, int> categories = {
  'general': 0,
  'species': 5,
  'character': 4,
  'copyright': 3,
  'meta': 7,
  'lore': 8,
  'artist': 1,
  'invalid': 6,
};

Map<String, int> countTags(List<String> tags, [Map<String, int>? counts]) {
  counts ??= {};

  for (String tag in tags) {
    counts[tag] = (counts[tag] ?? 0) + 1;
  }

  return counts;
}

List<CountedTag> countTagsByItems<T>(List<T> items,
    List<String> Function(T element, String category) getCategory) {
  Map<String, Map<String, int>> categoryCounts = {};
  for (String category in categories.keys) {
    categoryCounts[category] = {};
  }

  for (T item in items) {
    for (String category in categories.keys) {
      List<String> tags = getCategory(item, category);
      categoryCounts[category] = countTags(tags, categoryCounts[category]);
    }
  }

  List<CountedTag> counted = [];

  for (MapEntry<String, Map<String, int>> category in categoryCounts.entries) {
    for (MapEntry<String, int> tags in category.value.entries) {
      counted.add(CountedTag(
        category: category.key,
        tag: tags.key,
        count: tags.value,
      ));
    }
  }

  return counted;
}

List<CountedTag> countTagsBySlims(List<SlimPost> storage) {
  return countTagsByItems<SlimPost>(
      storage, (element, category) => element.tags[category] ?? []);
}
