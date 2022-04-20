import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';

class BlacklistSettings extends StatefulWidget {
  const BlacklistSettings();

  @override
  _BlacklistSettingsState createState() => _BlacklistSettingsState();
}

class _BlacklistSettingsState extends State<BlacklistSettings> {
  bool isEditing = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: settings.blacklist,
      builder: (context, blacklist, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Blacklist'),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                List<String> updated = controller.text.split('\n');
                updated = updated.map((e) => e.trim()).toList();
                updated.removeWhere((element) => element.isEmpty);
                settings.blacklist.value = updated;
              } else {
                controller.text = blacklist.join('\n');
                controller.selection = TextSelection(
                  baseOffset: controller.text.length,
                  extentOffset: controller.text.length,
                );
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedSize(
              duration: defaultAnimationDuration,
              child: isEditing
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.multiline,
                                    autofocus: true,
                                    decoration: const InputDecoration(
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
                    )
                  : CrossFade(
                      showChild: blacklist.isNotEmpty,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => ListTile(
                          title: Wrap(
                            children: blacklist[index]
                                .split(' ')
                                .map(
                                  (e) => Card(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      child: Text(e),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: blacklist.length,
                      ),
                      secondChild: const Center(
                        child: Text('your blacklist is empty'),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
