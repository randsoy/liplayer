import 'package:flutter/material.dart';

class SettingMenu extends StatelessWidget {
  const SettingMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // action button
      icon: const Icon(Icons.settings),
      onPressed: () {
        debugPrint("Click Menu Setting");
      },
    );
  }
}

class LiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LiAppBar({Key? key, required this.title, this.actions})
      : super(key: key);

  final String title;
  final List<Widget>? actions;

  const LiAppBar.defaultSetting({super.key, required this.title})
      : actions = null;
  // todo settings page
  //: actions=<Widget>[SettingMenu()];

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        title: Text(title),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(45.0);
}
