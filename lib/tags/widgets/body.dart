import 'package:collection/collection.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/tags/data/count.dart';
import 'package:e305/tags/data/score.dart';
import 'package:flutter/material.dart';

class TagBody extends StatefulWidget {
  final Post post;
  final SearchCallback? onSearch;
  final PostController? controller;

  const TagBody({required this.post, this.onSearch, this.controller});

  @override
  _TagBodyState createState() => _TagBodyState();
}

class _TagBodyState extends State<TagBody> {
  List<ScoredTag>? scores;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null &&
        widget.controller is RecommendationController &&
        (widget.controller as RecommendationController).favs.value != null) {
      List<CountedTag> counts = countTagsBySlims(
          (widget.controller as RecommendationController).favs.value!);
      scores = createScoreTable(counts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (widget.post.tags.entries
          .where((category) => category.value.isNotEmpty)
          .map<Widget>(
            (category) => Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(indent: 4, endIndent: 4),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          category.key,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(fontSize: 16),
                        ),
                      ),
                      Wrap(
                        children: category.value.map(
                          (tag) {
                            double? score = scores
                                ?.singleWhereOrNull(
                                    (element) => element.tag == tag)
                                ?.score;

                            return Card(
                              child: InkWell(
                                onTap: () => widget.onSearch?.call(tag),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Text(tag),
                                    ),
                                    if (score != null) ...[
                                      Container(
                                        color: Theme.of(context).dividerColor,
                                        width: 2,
                                        height: 14,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: Text(score.toStringAsFixed(4)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList()),
    );
  }
}
