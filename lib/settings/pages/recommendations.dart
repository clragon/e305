import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/recommendations/widgets/recommendations.dart';
import 'package:flutter/material.dart';

class RecommendationDatabaseText extends StatelessWidget {
  final RecommendationStatus status;

  const RecommendationDatabaseText({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case RecommendationStatus.loading:
        return Row(
          children: const [
            Text('database is being created'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: PulseLoadingIndicator(size: 14),
            ),
          ],
        );
      case RecommendationStatus.anonymous:
        return const Text('you are not logged in');
      case RecommendationStatus.insufficient:
        return const Text(
            'you dont have enough favorites.\nclick here after you favorited some posts!');
      case RecommendationStatus.functional:
        return const Text('recreate favorite tag database');
    }
  }
}

class TagChangeDialog extends StatefulWidget {
  final void Function(String value) onSubmit;
  final TextEditingController controller;
  final String title;
  final String hint;

  const TagChangeDialog({
    required this.title,
    required this.hint,
    required this.onSubmit,
    required this.controller,
  });

  @override
  _TagChangeDialogState createState() => _TagChangeDialogState();
}

class _TagChangeDialogState extends State<TagChangeDialog> {
  void submit() {
    widget.onSubmit(widget.controller.text.trim());
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        autofocus: true,
        controller: widget.controller,
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(
          hintText: widget.hint,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          onPressed: Navigator.of(context).maybePop,
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: submit,
        ),
      ],
    );
  }
}
