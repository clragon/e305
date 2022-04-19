import 'package:e305/client/data/client.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/comments/widgets/body.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/data/image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'detail/artists.dart';
import 'detail/description.dart';
import 'detail/file.dart';
import 'detail/image.dart';
import 'detail/interactions.dart';
import 'detail/recommendation.dart';
import 'detail/relations.dart';
import 'detail/tags.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final PostController? controller;

  const PostDetail({required this.post, this.controller});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  ScrollController scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!['webm', 'mp4'].contains(widget.post.file.ext)) {
      preloadImage(context: context, post: widget.post, size: ImageSize.file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TransparentAppBar(
        child: AppBar(
          flexibleSpace: const ScrollToTop(),
          actions: [
            PopupMenuButton<VoidCallback>(
              icon: const Icon(
                Icons.more_vert,
              ),
              onSelected: (value) => value(),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: () async =>
                      launch('https://${client.host}/posts/${widget.post.id}'),
                  child: Row(
                    children: const [
                      Icon(
                        FontAwesomeIcons.externalLinkAlt,
                        size: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text('Browse'),
                      ),
                    ],
                  ),
                ),
                if (widget.controller is RecommendationController)
                  PopupMenuItem(
                    value: () async => showDialog(
                      context: context,
                      builder: (context) => RecommendationScoreDialog(
                        post: widget.post,
                        controller:
                            widget.controller as RecommendationController,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          FontAwesomeIcons.star,
                          size: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text('Recommendation'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: MediaQuery.removeViewInsets(
        context: context,
        removeTop: true,
        child: ExpandableTheme(
          data: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: Theme.of(context).iconTheme.color,
          ),
          child: CommentAppender(
            scrollController: scrollController,
            post: widget.post,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ImageDisplay(post: widget.post),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ArtistDisplay(post: widget.post),
                      const Divider(),
                      InteractionDisplay(post: widget.post),
                      const Divider(),
                      DescriptionDisplay(
                        post: widget.post,
                      ),
                      // no divider here
                      RelationDisplay(post: widget.post),
                      // no divider here
                      TagDisplay(post: widget.post),
                      const Divider(),
                      FileDisplay(post: widget.post),
                      const Divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
