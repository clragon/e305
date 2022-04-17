import 'package:e305/client/models/post.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:flutter/material.dart';

class TagBody extends StatelessWidget {
  final Post post;
  final SearchCallback? onSearch;

  const TagBody({required this.post, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (post.tags.entries
          .where((category) => category.value.isNotEmpty)
          .map<Widget>(
            (category) => Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
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
                                  onTap: () => onSearch?.call(tag),
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
                ),
              ],
            ),
          )
          .toList()),
    );
  }
}
