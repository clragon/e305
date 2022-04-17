import 'dart:math';

import 'package:flutter/material.dart';

class DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const DefaultErrorWidget(this.details);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigoAccent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double scale = min(constraints.maxWidth, constraints.maxHeight);

          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      right: scale * 0.05, bottom: scale * 0.05),
                  child: Text(
                    ':(',
                    style: TextStyle(fontSize: scale * 0.2),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Something\nWent Wrong',
                    style: TextStyle(fontSize: scale * 0.085),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
