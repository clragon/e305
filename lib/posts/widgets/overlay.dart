import 'package:e305/client/models/post.dart';
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
