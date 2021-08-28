import 'dart:math';

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

  const PostScoreOverly({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (post.recommendationValue == null) {
      return SizedBox.shrink();
    }

    double maxScore = 0;
    for (Post post in controller.itemList!) {
      maxScore = max(post.recommendationValue!, maxScore);
    }

    // 1 / maxScore *

    String displayScore = (post.recommendationValue!).toStringAsFixed(2);

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
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              height: 20,
              width: 20,
              child: Text(
                displayScore,
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
                heightFactor: ((1 / maxScore) * post.recommendationValue!),
                child: Container(
                  color: Theme.of(context).accentColor,
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
