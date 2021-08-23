import 'package:e305/client/data/client.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/profile/widgets/icon.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({Key? key}) : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  bool? hasLogin;

  Future<void> updateLogin() async {
    hasLogin = await client.hasLogin;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateLogin();
    settings.credentials.addListener(updateLogin);
  }

  @override
  void dispose() {
    settings.credentials.removeListener(updateLogin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeCrossFade(
      showChild: hasLogin != null && hasLogin!,
      builder: (context) => Column(
        children: [
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                IgnorePointer(child: ProfileButton()),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, right: 8),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'write a comment...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
