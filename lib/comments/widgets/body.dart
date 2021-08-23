import 'package:e305/client/models/comment.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/comments/data/controller.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'comment.dart';
import 'input.dart';

class CommentAppender extends StatefulWidget {
  final ScrollController? scrollController;
  final Widget? child;
  final Post post;

  const CommentAppender(
      {required this.post, this.child, this.scrollController});

  @override
  _CommentAppenderState createState() => _CommentAppenderState();
}

class _CommentAppenderState extends State<CommentAppender> {
  late CommentController controller = CommentController(post: widget.post);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator() {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: PulseLoadingIndicator(size: 60)),
      );
    }

    return CustomScrollView(
      controller: widget.scrollController,
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: widget.child,
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Comments',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                CommentInput(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          sliver: PagedSliverList(
            pagingController: controller,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (BuildContext context, Comment item, int index) =>
                  CommentTile(comment: item),
              firstPageProgressIndicatorBuilder: (context) =>
                  loadingIndicator(),
              newPageProgressIndicatorBuilder: (context) => loadingIndicator(),
              noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'no comments',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 16),
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }
}
