import 'package:e305/posts/data/post.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ArtistDisplay extends StatelessWidget {
  final Post post;
  final SearchCallback onSearch;

  const ArtistDisplay({required this.post, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    List<String>? artists = post.tags['artist'];

    artists?.removeWhere((artist) => [
          'epilepsy_warning',
          'conditional_dnp',
          'sound_warning',
          'avoid_posting',
        ].contains(artist));

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              FontAwesomeIcons.user,
              size: 20,
            ),
          ),
          artists?.isNotEmpty ?? false
              ? InkWell(
                  onTap: () {
                    Navigator.of(context).maybePop();
                    onSearch(artists!.join(' '));
                  },
                  child: Text(
                    artists!.join(', '),
                  ),
                )
              : const Text(
                  'no artist',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
        ],
      ),
    );
  }
}
