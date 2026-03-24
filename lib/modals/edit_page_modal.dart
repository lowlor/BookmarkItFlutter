import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:bookmarkit/services/bookmark_service.dart';
import 'package:bookmarkit/utils/dialogs/confirm_create_edit_dialog.dart';
import 'package:bookmarkit/utils/dialogs/delete_single_dialog.dart';
import 'package:bookmarkit/utils/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

Future<void> editPageModel(
  BuildContext context,
  BookmarkService bookmarkService,
  BookmarkDatabase bookmark,
) {
  //late File _file;

  late Uint8List image;
  final ImagePicker imgPick = ImagePicker();

  TextEditingController titleController = TextEditingController();
  TextEditingController titleAlternativeController = TextEditingController();
  TextEditingController webUrlController = TextEditingController();
  TextEditingController episodeController = TextEditingController();
  StreamController<Uint8List> imageController = StreamController<Uint8List>();
  imageController = StreamController.broadcast(
    onListen: () {
      imageController.sink.add(image);
    },
  );

  titleController.text = bookmark.title;
  titleAlternativeController.text = bookmark.titleAlternative;
  webUrlController.text = bookmark.webUrl;
  episodeController.text = bookmark.episode.toString();
  image = bookmark.image;

  Future<void> pickImage() async {
    final file = await imgPick.pickImage(
      source: ImageSource.gallery,
      maxHeight: 480,
      maxWidth: 640,
    );
    if (file != null) {
      final imageFile = File(file.path);
      final imageByte = await imageFile.readAsBytes();
      image = imageByte;
      imageController.add(image);
    } else {
      //for show dialog
    }
  }

  Future<void> onUpdateData() async {
    try {
      final title = titleController.text;
      final titleAlternative = titleAlternativeController.text;
      final webUrl = webUrlController.text;
      final episode = double.parse(episodeController.text);
      log('$title, $episode');

      await bookmarkService.updateBookmark(
        bookmark.id,
        title,
        titleAlternative,
        webUrl,
        episode,
        image,
      );

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        await showErrorDialog(
          context,
          'We have problem in creating new bookmark',
        );
      }
    }
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StreamBuilder(
        stream: imageController.stream,
        builder: (context, asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.active:
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 234, 234, 234),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.78,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async => await pickImage(),
                              child: SizedBox(
                                width: 350,
                                height: 350,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(image),
                                      fit: BoxFit.cover,
                                      alignment: FractionalOffset.center,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ), //fit: BoxFit.fit,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: "title",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              controller: titleAlternativeController,
                              decoration: InputDecoration(
                                hintText: "title alternative",
                              ),
                            ),
                            TextField(
                              controller: webUrlController,
                              decoration: InputDecoration(hintText: "web url"),
                            ),
                            TextField(
                              controller: episodeController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'(^\d*\.?\d{00,99})'),
                                ),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(hintText: "episode"),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SizedBox(
                                    width: 200,
                                    height: 40,
                                    child: TextButton(
                                      onPressed: () async {
                                        final bool wantUpdate =
                                            await confirmCreateEditDialog(
                                              context,
                                              'Do you want to edit bookmark?',
                                            );
                                        if (wantUpdate) {
                                          onUpdateData();
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        overlayColor: Colors.black,
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          95,
                                          95,
                                          95,
                                        ),
                                      ),
                                      child: const Text(
                                        "Save",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () async {
                                    final wantDelete = await deleteSingleDialog(
                                      context,
                                    );
                                    log(wantDelete.toString());
                                    if (wantDelete) {
                                      await bookmarkService.deleteBookmark(
                                        bookmark.id,
                                      );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    overlayColor: Colors.black,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      95,
                                      95,
                                      95,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );

            default:
              return Container();
          }
        },
      );
    },
  );
}
