import 'package:e305/interface/widgets/search.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/recommendations/data/score.dart';
import 'package:e305/tags/data/count.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'expand.dart';

class RecommendationScoreDialog extends StatelessWidget {
  final Post post;
  final RecommendationController controller;

  const RecommendationScoreDialog({
    required this.post,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recommendation'),
      content: RecommendationBody(
        post: post,
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).maybePop,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class RecommendationDisplay extends StatefulWidget {
  final Post post;
  final SearchCallback? onSearch;
  final PostController? controller;

  const RecommendationDisplay({
    required this.post,
    this.onSearch,
    this.controller,
  });

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
        widget.post.recommendationValue == null ||
        widget.post.recommendedTags == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpandableDefaultParent(
          builder: (context, controller) => ExpandablePanel(
            key: ObjectKey(controller),
            controller: controller,
            collapsed: const SizedBox.shrink(),
            header: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Recommendation',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            expanded: RecommendationBody(
              post: widget.post,
              controller: widget.controller as RecommendationController,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class RecommendationBody extends StatelessWidget {
  final Post post;
  final RecommendationController controller;

  const RecommendationBody({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    double maxScore = controller.maxScore();
    double relativeScore = 1 / maxScore * post.recommendationValue!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  post.recommendationValue!.toStringAsFixed(2),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 255, 215, 0),
                ),
                value: relativeScore,
              ),
            )
          ],
        ),
        Expanded(
          child: Wrap(
            children: post.recommendedTags!.map(
              (tag) {
                return Card(
                  child: InkWell(
                    onTap: SearchProvider.of(context) != null
                        ? () => SearchProvider.of(context)!.call(tag.tag)
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Text(tag.tag),
                        ),
                        Container(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                          height: 14,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child:
                              Text((tag.score * tag.weigth).toStringAsFixed(2)),
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
    );
  }
}
