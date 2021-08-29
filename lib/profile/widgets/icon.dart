import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/client/data/client.dart';
import 'package:e305/profile/widgets/profile.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileButton extends StatefulWidget {
  const ProfileButton();

  @override
  _ProfileButtonState createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  String? avatar;

  Future<void> updateAvatar() async {
    avatar = await client.avatar;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    settings.credentials.addListener(updateAvatar);
    updateAvatar();
  }

  @override
  void dispose() {
    settings.credentials.removeListener(updateAvatar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 32,
      icon: avatar != null
          ? CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(avatar!),
              radius: 36,
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              child: Icon(
                FontAwesomeIcons.user,
                size: 16,
              ),
            ),
      onPressed: avatar != null
          ? () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => ProfileDetail(),
                ),
              );
            }
          : null,
    );
  }
}
