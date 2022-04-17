import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail();

  @override
  _ProfileDetailState createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                FontAwesomeIcons.tools,
                size: 20,
              ),
            ),
            Text(
              'Work in progress!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
