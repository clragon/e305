import 'package:e305/client/models/post.dart';
import 'package:e305/posts/data/interactions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InteractionDisplay extends StatefulWidget {
  final Post post;

  const InteractionDisplay({required this.post});

  @override
  _InteractionDisplayState createState() => _InteractionDisplayState();
}

class _InteractionDisplayState extends State<InteractionDisplay> {
  VoteStatus voteStatus = VoteStatus.unknown;
  late bool initialFav = widget.post.isFavorited;

  Color? getVoteColor(VoteStatus voteStatus) {
    switch (voteStatus) {
      case VoteStatus.upvoted:
        return Colors.deepOrange;
      case VoteStatus.downvoted:
        return Colors.blueAccent;
      case VoteStatus.unknown:
        return null;
    }
  }

  int getVoteCount(int voteCount) {
    int current = widget.post.score.total;
    switch (voteStatus) {
      case VoteStatus.upvoted:
        return current + 1;
      case VoteStatus.downvoted:
        return current - 1;
      case VoteStatus.unknown:
        return current;
    }
  }

  int getFavCount() {
    if (initialFav == widget.post.isFavorited) {
      return widget.post.favCount;
    }
    if (initialFav) {
      return widget.post.favCount - 1;
    } else {
      return widget.post.favCount + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget favButton() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              getFavCount().toString(),
              style: TextStyle(
                color: widget.post.isFavorited ? Colors.pink : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () => toggleFavorite(
              context: context,
              post: widget.post,
              current: widget.post.isFavorited,
              onChange: (value) => setState(() {
                widget.post.isFavorited = value;
              }),
            ),
            icon: Icon(
              FontAwesomeIcons.solidHeart,
              size: 20,
              color: widget.post.isFavorited ? Colors.pink : null,
            ),
          ),
        ],
      );
    }

    Widget downloadButton() {
      return IconButton(
        onPressed: () {},
        icon: Icon(
          FontAwesomeIcons.download,
          size: 20,
        ),
      );
    }

    Widget scoreButton() {
      return Row(
        children: [
          IconButton(
            onPressed: () => vote(
              context: context,
              upvote: true,
              post: widget.post,
              current: voteStatus,
              onChange: (value) => setState(() => voteStatus = value),
            ),
            icon: Icon(
              FontAwesomeIcons.arrowUp,
              size: 20,
              color:
                  voteStatus == VoteStatus.upvoted ? Colors.deepOrange : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              getVoteCount(widget.post.score.total).toString(),
              style: TextStyle(color: getVoteColor(voteStatus)),
            ),
          ),
          IconButton(
            onPressed: () => vote(
              context: context,
              upvote: false,
              post: widget.post,
              current: voteStatus,
              onChange: (value) => setState(() => voteStatus = value),
            ),
            icon: Icon(
              FontAwesomeIcons.arrowDown,
              size: 20,
              color:
                  voteStatus == VoteStatus.downvoted ? Colors.blueAccent : null,
            ),
          ),
        ],
      );
    }

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(child: scoreButton()),
            Row(children: [downloadButton()]),
            Expanded(child: favButton()),
          ],
        ),
      ),
    );
  }
}
