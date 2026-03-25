import 'dart:async';
import 'dart:developer';

import 'package:bookmarkit/modals/create_page_modal.dart';
import 'package:bookmarkit/services/bookmark_service.dart';
import 'package:bookmarkit/services/file_service.dart';
import 'package:bookmarkit/utils/dialogs/delete_all_dialog.dart';
import 'package:bookmarkit/views/home_page_list_view.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final BookmarkService bookmarkService;
  late final FileService _fileService;
  late StreamSubscription _intentSub;
  late final Future<String> _initFuture;

  @override
  initState() {
    super.initState();
    _fileService = FileService();
    bookmarkService = BookmarkService();
    _initFuture = bookmarkService.initialize();

    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) async {
        if (value.isEmpty) return;
        await _initFuture;
        if (context.mounted)
          createPageModal(
            fromShare: true,
            textFromShare: value.map((f) => f.toMap()).first['path'] as String,
            context: context,
            bookmarkService: bookmarkService,
          );
      },
      onError: (err) {
        log(err);
      },
    );

    ReceiveSharingIntent.instance.getInitialMedia().then((value) async {
      if (value.isEmpty) return;
      await _initFuture;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        createPageModal(
          fromShare: true,
          textFromShare: value.map((f) => f.toMap()).first['path'] as String,
          context: context,
          bookmarkService: bookmarkService,
        );
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  @override
  dispose() {
    bookmarkService.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bookmark'),
        backgroundColor: Colors.white,
        elevation: 10.0,
        actions: [
          IconButton(
            onPressed: () async {
              final wantDeleteAll = await deleteAllDialog(context);
              if (wantDeleteAll) {
                await bookmarkService.deleteAllBookmark();
              }
            },
            icon: Icon(Icons.delete, color: Colors.black),
          ),
        ],
      ),
      drawer: Drawer(
        width: 300,
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Image(
              image: AssetImage('assets/drawer_icon.png'),
              height: 200,
              width: 200,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: const Text('Bookmark', style: TextStyle(fontSize: 30)),
            ),
            SizedBox(height: 2, child: ColoredBox(color: Colors.grey)),
            ListTile(
              onTap: () async {
                await _fileService.import();
                await bookmarkService.openDbAfterImport();
                if (context.mounted) Navigator.pop(context);
              },
              title: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.import_export),
                    const SizedBox(width: 8),
                    const Text('Import'),
                  ],
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                await _fileService.export();
                if (context.mounted) Navigator.pop(context);
              },
              title: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.import_export),
                    const SizedBox(width: 8),
                    const Text('Export'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          createPageModal(context: context, bookmarkService: bookmarkService);
        },
        child: Icon(Icons.add, color: Colors.black),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
            if (asyncSnapshot.hasData) {
                return StreamBuilder(
                  stream: bookmarkService.allBookmark,
                  builder: (context, asyncSnapshot) {
                    switch (asyncSnapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (asyncSnapshot.hasData) {
                          final bookmarks =
                              asyncSnapshot.data as List<BookmarkDatabase>;
                          return HomePageListView(
                            bookmarks: bookmarks,
                            bookmarkService: bookmarkService,
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      default:
                        return CircularProgressIndicator();
                    }
                  },
                );
              } else {
                return Container();
              }
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
