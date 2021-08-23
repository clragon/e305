import 'package:e305/client/data/client.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';

mixin HostMixin<T extends StatefulWidget> on State<T> {
  Future<bool> get safe => client.safe;

  Future<void> onHostChange() async {}

  Future<void> updateSafety() async {
    await client.host;
    await onHostChange();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    settings.safe.addListener(updateSafety);
  }
}
