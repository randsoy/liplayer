import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'video_page.dart';

class LocalPathScreen extends StatelessWidget {
  const LocalPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LiAppBar.defaultSetting(title: "Local Path"),
      body: LocalPath(),
    );
  }
}

final RegExp _mediaReg = RegExp(".(flv|mp4|mkv|mp3|mp4)\$");

class LocalPath extends StatefulWidget {
  const LocalPath({super.key});

  @override
  createState() => _LocalPathState();
}

class _LocalPathState extends State<LocalPath> {
  bool root = true;

  List<FileSystemEntity> files = [];
  Directory current = Directory.current;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
  }

  void cantOpenSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Something error when opening this file/dir'),
    ));
    // Scaffold.of(context).showSnackBar(const SnackBar(
    //   duration: Duration(seconds: 1),
    //   content: Text('Something error when opening this file/dir'),
    // ));
  }

  void listDir(String path) {
    bool opened = true;
    if (kDebugMode) {
      print("list path:$path");
    }
    List<FileSystemEntity> tmpFiles = [];
    FileSystemEntity.isDirectory(path).then((f) {
      if (f) {
        final Directory dir = Directory(path);
        tmpFiles.add(dir.parent);
        _subscription = dir.list(followLinks: false).listen((child) {
          if (FileSystemEntity.isDirectorySync(child.path) ||
              _mediaReg.hasMatch(child.path)) {
            tmpFiles.add(child);
          }
        }, onDone: () {
          if (opened == true) {
            setState(() {
              files = tmpFiles;
              current = dir;
            });
          }
        }, onError: (e) {
          opened = false;
          cantOpenSnackBar();
        });
      }
    }).catchError((e) {
      cantOpenSnackBar();
    });
  }

  Widget buildItem(FileSystemEntity entity, int parentLength, bool isDir) {
    final String path = entity.absolute.path;
    final bool parent = path.length <= parentLength;
    final text = parent ? ".." : path.substring(parentLength + 1);
    final IconData icon = isDir ? Icons.folder : Icons.music_video;

    return TextButton(
      key: ValueKey(path),
      // padding: EdgeInsets.only(left: 5, right: 5),
      child: Row(children: <Widget>[
        Icon(icon),
        const Padding(padding: EdgeInsets.only(left: 5)),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ]),
      onPressed: () {
        if (isDir) {
          listDir(entity.absolute.path);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      VideoScreen(url: entity.absolute.path)));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    int currentLength = current.absolute.path.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          title: Text(current.path,
              style: TextStyle(
                color: Theme.of(context).dividerColor,
                fontSize: 14,
              )),
          contentPadding: const EdgeInsets.only(left: 10),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (BuildContext context, int index) {
                FileSystemEntity entity = files[index];
                bool isDir = FileSystemEntity.isDirectorySync(entity.path);
                if (kDebugMode) {
                  print("builditem ${entity.path}, $currentLength, $isDir");
                }
                return buildItem(entity, currentLength, isDir);
              }),
        )
      ],
    );
  }
}
