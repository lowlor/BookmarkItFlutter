import 'package:bookmarkit/modals/create_page_modal.dart';
import 'package:bookmarkit/modals/edit_page_modal.dart';
import 'package:bookmarkit/services/bookmark_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: HomeView(),
    ),
  );
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final BookmarkService _bookmarkService;
  late final Future<String> _initFuture; 
  @override
  initState() {
    _bookmarkService = BookmarkService();
    _initFuture  = _bookmarkService.initialize();
    super.initState();
  }

  @override
  dispose() async {
    await _bookmarkService.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Title', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              createPageModel(context, _bookmarkService);
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            onPressed: () async {
              await _bookmarkService.deleteAllBookmark();
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              if (asyncSnapshot.hasData) {
                return StreamBuilder(
                  stream: _bookmarkService.allBookmark,
                  builder: (context, asyncSnapshot) {
                    switch (asyncSnapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (asyncSnapshot.hasData) {
                          final bookmarks =
                              asyncSnapshot.data as List<BookmarkDatabase>;
                          return ListView.builder(
                            itemCount: bookmarks.length,
                            itemBuilder: (context, index) {
                              final bookmark = bookmarks[index];
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                child: Card(
                                  child: InkWell(
                                    onLongPress: () async {
                                      final BookmarkDatabase bookmarkToUse = await _bookmarkService.getBookmark(
                                      bookmark.id,
                                      );
                                      // ignore: use_build_context_synchronously
                                      await editPageModel(context, _bookmarkService, bookmarkToUse);
                                    },
                                    onTap: () async {
                                      final Uri url = Uri.parse(
                                        bookmark.webUrl,
                                      );
                                      if (!await launchUrl(url)) {
                                        throw Exception('error');
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Image(
                                          image: MemoryImage(bookmark.image),
                                          width: 100,
                                          height: 100,
                                        ),
                                        Column(
                                          children: [
                                            Text(bookmark.title),
                                            Text(bookmark.titleAlternative),
                                            Text((bookmark.episode).toString()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
