import 'package:e305/posts/data/post.dart';

bool isBlacklisted(List<String> blacklist, Post post) {
  if (blacklist.isNotEmpty) {
    List<String> tags = post.tags.entries.fold(
      [],
      (previousValue, element) => previousValue..addAll(element.value),
    );

    for (String entry in blacklist) {
      List<String> deny = [];
      List<String> allow = [];
      entry.split(' ').forEach((tag) {
        if (tag.isNotEmpty) {
          if (tag[0] == '-') {
            allow.add(tag.substring(1));
          } else {
            deny.add(tag);
          }
        }
      });

      bool checkTags(List<String> tags, String tag) => tags.contains(tag);
      bool denied = deny.every((tag) => checkTags(tags, tag));
      bool allowed = allow.any((tag) => checkTags(tags, tag));

      if (denied && !allowed) {
        return true;
      }
    }
  }
  return false;
}
