import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BlacklistSettings extends StatefulWidget {
  const BlacklistSettings();

  @override
  _BlacklistSettingsState createState() => _BlacklistSettingsState();
}

class _BlacklistSettingsState extends State<BlacklistSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                FontAwesomeIcons.tools,
                size: 20,
              ),
            ),
            Text(
              'Uhh... this is awkward.\nWe arent done with this screen yet!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
