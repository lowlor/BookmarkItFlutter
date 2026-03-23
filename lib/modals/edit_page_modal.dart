import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bookmarkit/services/bookmark_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> editPageModel(
  BuildContext context,
  BookmarkService bookmarkService,
  BookmarkDatabase bookmark
) {
  //late File _file;

  late Uint8List image;
  final ImagePicker imgPick = ImagePicker();
  
  TextEditingController titleController = TextEditingController();
  TextEditingController titleAlternativeController = TextEditingController();
  TextEditingController webUrlController = TextEditingController();
  TextEditingController episodeController = TextEditingController();

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
    } else {
      //for show dialog
    }
  }

  Future<void> onUpdateData() async {
    final title = titleController.text;
    final titleAlternative = titleAlternativeController.text;
    final webUrl = webUrlController.text;
    final episode = double.parse(episodeController.text);
    
    await bookmarkService.updateBookmark(
      bookmark.id,
      title,
      titleAlternative,
      webUrl,
      episode,
      image,
    );

    if (context.mounted) Navigator.of(context).pop();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: InkWell(
                    onTap: () async => await pickImage(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: BoxBorder.all(width: 2),
                      ),
                      child: Center(child: const Text('pick')),
                    ),
                  ),
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "title"),
                ),
                TextField(
                  controller: titleAlternativeController,
                  decoration: InputDecoration(hintText: "title alternative"),
                ),
                TextField(
                  controller: webUrlController,
                  decoration: InputDecoration(hintText: "web url"),
                ),
                TextField(
                  controller: episodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "episode"),
                ),
                TextButton(
                  onPressed: () {
                    onUpdateData();
                  },
                  child: SizedBox(
                    width: 100,
                    child: Center(child: const Text('save')),
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
