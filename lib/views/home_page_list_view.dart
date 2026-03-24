
import 'package:bookmarkit/modals/edit_page_modal.dart';
import 'package:bookmarkit/services/bookmark_service.dart';
import 'package:bookmarkit/utils/dialogs/error_dialog.dart';
import 'package:bookmarkit/utils/formats/format_correct_web.dart';
import 'package:bookmarkit/utils/formats/format_episode_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageListView extends StatelessWidget {
  final List<BookmarkDatabase> bookmarks;
  final BookmarkService bookmarkService;
  const HomePageListView({
    super.key,
    required this.bookmarks,
    required this.bookmarkService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookmarks.length,
      padding: EdgeInsets.only(top: 5),
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Card(
            color: Colors.white,
            child: InkWell(
              onLongPress: () async {
                final BookmarkDatabase bookmarkToUse = await bookmarkService
                    .getBookmark(bookmark.id);
                // ignore: use_build_context_synchronously
                await editPageModel(context, bookmarkService, bookmarkToUse);
              },
              onTap: () async {
                try {
                  final Uri url = Uri.parse(formatCorrectWeb(bookmark.webUrl));
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  if (context.mounted) {
                    await showErrorDialog(
                      context,
                      "Have problem in accessing the url (${bookmark.webUrl})",
                    );
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 6),
                  Material(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(bookmark.image),
                            fit: BoxFit.cover,
                            alignment: FractionalOffset.center,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 174,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        //border: BoxBorder.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            bookmark.title,
                            style: TextStyle(fontSize: 20),
                            softWrap: true,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            bookmark.titleAlternative,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          SizedBox(
                            height: 2,
                            width: 160,
                            child: ColoredBox(color: Colors.grey),
                          ),
                          Spacer(),
                          Align(
                            alignment: AlignmentGeometry.bottomEnd,
                            child: Text(
                              formatEpisodeText(bookmark.episode.toString()),
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
