import 'package:e305/client/models/post.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/tags/data/count.dart';
import 'package:e305/tags/data/score.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'expand.dart';

class RecommendationDisplay extends StatefulWidget {
  final Post post;
  final bool? expanded;
  final SearchCallback? onSearch;
  final PostController? controller;

  const RecommendationDisplay(
      {required this.post, this.onSearch, this.controller, this.expanded});

  @override
  _RecommendationDisplayState createState() => _RecommendationDisplayState();
}

class _RecommendationDisplayState extends State<RecommendationDisplay> {
  List<ScoredTag>? scores;

  Future<void> initScores() async {
    if (widget.controller != null &&
        widget.controller is RecommendationController &&
        (widget.controller as RecommendationController).favs.value != null) {
      List<CountedTag> counts = countTagsBySlims(
          (widget.controller as RecommendationController).favs.value!);
      scores = createScoreTable(counts);
    }
  }

  @override
  void initState() {
    super.initState();
    initScores();
  }

  @override
  Widget build(BuildContext context) {
    if (scores == null ||
        widget.post.recommendationValue != null ||
        widget.post.recommendedTags != null) {
      return SizedBox.shrink();
    }

    double maxScore =
        (widget.controller as RecommendationController).maxScore();
    double relativeScore = 1 / maxScore * widget.post.recommendationValue!;

    return Column(
      children: [
        ExpandableParent(
          expanded: widget.expanded,
          builder: (context, controller) => ExpandablePanel(
            key: ObjectKey(controller),
            controller: controller,
            collapsed: SizedBox.shrink(),
            header: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recommendation',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            expanded: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                          ],
                          radius: 0.5,
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          widget.post.recommendationValue!.toStringAsFixed(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 255, 215, 0),
                        ),
                        value: relativeScore,
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Wrap(
                    children: widget.post.recommendedTags!.map(
                      (tag) {
                        return Card(
                          child: InkWell(
                            onTap: () => widget.onSearch?.call(tag.tag),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Text(tag.tag),
                                ),
                                Container(
                                  color: Theme.of(context).dividerColor,
                                  width: 2,
                                  height: 14,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  child: Text((tag.score * tag.weigth)
                                      .toStringAsFixed(2)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
