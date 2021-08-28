import 'package:e305/client/models/post.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostTileOverlay extends StatelessWidget {
  final Post post;

  const PostTileOverlay({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: Column(
        children: [
          if (post.file.ext == 'webm')
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                FontAwesomeIcons.playCircle,
                size: 20,
              ),
            ),
          if (post.pools.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                FontAwesomeIcons.layerGroup,
                size: 20,
              ),
            ),
          if (post.isFavorited)
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                FontAwesomeIcons.solidHeart,
                size: 20,
              ),
            )
        ],
      ),
    );
  }
}

class PostScoreOverly extends StatelessWidget {
  final Post post;
  final PostController controller;
  final bool exact;

  const PostScoreOverly(
      {required this.post, required this.controller, this.exact = true});

  @override
  Widget build(BuildContext context) {
    if (post.recommendationValue == null ||
        !(controller is RecommendationController)) {
      return SizedBox.shrink();
    }

    double maxScore = (controller as RecommendationController).maxScore();
    double relativeScore = 1 / maxScore * post.recommendationValue!;

    if (exact) {
      return ScoreMeterOverlay(
          score: post.recommendationValue!, relativeScore: relativeScore);
    }

    if (relativeScore > 0.75) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            FontAwesomeIcons.solidStar,
            size: 20,
            color: Color.fromARGB(255, 255, 215, 0),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class ScoreMeterOverlay extends StatelessWidget {
  final double score;
  final double relativeScore;

  const ScoreMeterOverlay({required this.score, required this.relativeScore});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
              height: 20,
              width: 20,
              child: Text(
                score.toStringAsFixed(2),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              color: Theme.of(context).canvasColor,
              width: 4,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: SizedBox(
              width: 4,
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: relativeScore,
                child: Container(
                  color: Color.fromARGB(255, 255, 215, 0),
                  width: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
