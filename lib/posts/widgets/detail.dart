import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/comments/widgets/body.dart';
import 'package:e305/interface/widgets/appbar.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/data/image.dart';
import 'package:e305/posts/widgets/detail/artists.dart';
import 'package:e305/posts/widgets/detail/image.dart';
import 'package:e305/posts/widgets/detail/interactions.dart';
import 'package:e305/posts/widgets/detail/relations.dart';
import 'package:e305/posts/widgets/detail/tags.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'detail/description.dart';
import 'detail/file.dart';

class PostDetail extends StatefulWidget {
  final SearchCallback onSearch;
  final String? hero;
  final Post post;
  final PostController? controller;

  const PostDetail(
      {required this.post, this.hero, required this.onSearch, this.controller});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  ScrollController scrollController = ScrollController();

  bool? expanded;

  Future<void> updateExpanded() async {
    expanded = await settings.expanded.value;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateExpanded();
  }

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
      appBar: ScrollToTopAppBar(
        controller: scrollController,
        builder: (context, gesture) {
          return TransparentAppBar(
            title: gesture(context),
            actions: [
              PopupMenuButton<VoidCallback>(
                icon: Icon(
                  Icons.more_vert,
                ),
                onSelected: (value) => value(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: () async => launch(
                        'https://${await client.host}/posts/${widget.post.id}'),
                    child: Row(
                      children: [
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
                ],
              ),
            ],
          );
        },
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
                  padding: EdgeInsets.only(bottom: 8),
                  child: ImageDisplay(post: widget.post, hero: widget.hero),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ArtistDisplay(
                        post: widget.post,
                        onSearch: widget.onSearch,
                      ),
                      Divider(),
                      InteractionDisplay(post: widget.post),
                      Divider(),
                      DescriptionDisplay(
                        post: widget.post,
                        expanded: expanded,
                      ),
                      // no divider here
                      RelationDisplay(
                        post: widget.post,
                        expanded: expanded,
                        onSearch: widget.onSearch,
                      ),
                      // no divider here
                      TagDisplay(
                        post: widget.post,
                        expanded: expanded,
                        onSearch: widget.onSearch,
                        postController: widget.controller,
                      ),
                      Divider(),
                      FileDisplay(post: widget.post, expanded: expanded),
                      Divider(),
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
