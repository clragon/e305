import 'package:e305/pools/data/pool.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/posts/widgets/image.dart';
import 'package:flutter/material.dart';

class PoolTile extends StatelessWidget {
  final Pool pool;
  final VoidCallback? onPressed;

  const PoolTile({
    required this.pool,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                pool.name.replaceAll('_', ' '),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 22, top: 8, bottom: 8, right: 12),
            child: Text(
              pool.postIds.length.toString(),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title(),
            if (pool.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 8,
                ),
                child: IgnorePointer(
                  child: Text(
                    pool.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .color!
                          .withOpacity(0.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PoolReaderTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onPressed;
  final String? hero;
  final double? width;

  const PoolReaderTile(
      {required this.post, this.hero, this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: post.file.width / post.file.height,
      child: Container(
        color: Theme.of(context).cardColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: Hero(
                    tag: hero ?? UniqueKey(),
                    child: FullPostImage(
                      post: post,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Container(),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
