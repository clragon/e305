import 'package:e305/interface/widgets/search.dart';
import 'package:e305/posts/data/post.dart';
import 'package:flutter/material.dart';

class TagBody extends StatelessWidget {
  final Post post;

  const TagBody({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (post.tags.entries
          .where((category) => category.value.isNotEmpty)
          .map(
            (category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(indent: 4, endIndent: 4),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    category.key,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(fontSize: 16),
                  ),
                ),
                Wrap(
                  children: category.value
                      .map(
                        (tag) => Card(
                          child: InkWell(
                            onTap: SearchProvider.of(context) != null
                                ? () => SearchProvider.of(context)!.call(tag)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(tag),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          )
          .toList()),
    );
  }
}
