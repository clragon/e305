import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';

class BlacklistSettings extends StatefulWidget {
  const BlacklistSettings();

  @override
  _BlacklistSettingsState createState() => _BlacklistSettingsState();
}

class _BlacklistSettingsState extends State<BlacklistSettings> {
  bool isEditing = false;
  List<String>? blacklist;
  TextEditingController controller = TextEditingController();

  Future<void> updateBlacklist() async {
    setState(() {
      blacklist = null;
    });
    blacklist = await settings.blacklist.value;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    settings.blacklist.addListener(updateBlacklist);
    updateBlacklist();
  }

  @override
  void dispose() {
    settings.blacklist.removeListener(updateBlacklist);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blacklist'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isEditing ? Icons.check : Icons.edit),
        onPressed: blacklist != null
            ? () async {
                if (isEditing) {
                  List<String> updated = controller.text.split('\n');
                  updated.removeWhere((element) => element.isEmpty);
                  settings.blacklist.value = Future.value(updated);
                } else {
                  controller.text = blacklist!.join('\n');
                  controller.selection = TextSelection(
                    baseOffset: controller.text.length,
                    extentOffset: controller.text.length,
                  );
                }
                setState(() {
                  isEditing = !isEditing;
                });
              }
            : null,
      ),
      body: SafeCrossFade(
        showChild: blacklist != null,
        builder: (context) => Padding(
          padding: EdgeInsets.all(8),
          child: SafeCrossFade(
            showChild: isEditing,
            builder: (context) => SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.multiline,
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Add tags to your blacklist...',
                            ),
                            maxLines: null,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            secondChild: CrossFade(
              showChild: blacklist!.isNotEmpty,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                  title: Wrap(
                    children: blacklist![index]
                        .split(' ')
                        .map(
                          (e) => Card(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Text(e),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                separatorBuilder: (context, index) => Divider(),
                itemCount: blacklist!.length,
              ),
              secondChild: Center(
                child: Text('your blacklist is empty'),
              ),
            ),
          ),
        ),
        secondChild: Center(
          child: OrbitLoadingIndicator(size: 100),
        ),
      ),
    );
  }
}
