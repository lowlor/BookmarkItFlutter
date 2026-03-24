import 'dart:developer';
import 'dart:io';

import 'package:bookmarkit/services/bookmark_service.dart' show dbName;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  Future<void> import() async {
    try {
      final docPath = await getApplicationDocumentsDirectory();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['db'],
      );
      if(result != null){
        final File oldBookmark = File(join(docPath.path,dbName));
        await oldBookmark.delete();
        final File newBookmark = File(result.files.single.path!);
        newBookmark.copy(join(docPath.path,dbName));
        
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> export() async {
    try {
      final docPath = await getApplicationDocumentsDirectory();
      //final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final results = await SharePlus.instance.share(
        ShareParams(
          text: 'Export a file',
          files: [XFile(join(docPath.path, dbName))],
        ),
      );
      //final downloadPath = await Directory('path')
      //if (Platform.isAndroid && deviceInfo.version.sdkInt <= 30) {
      //  if (await Permission.manageExternalStorage.request().isGranted) {
      //    log('granted');
      //  } else {
      //    log('not granted');
      //  }
      //} else {
      //  final dwnPath = Directory('/storage/emulated/0/Download');
      //  final File newDatabase = File(join(docPath.path, dbName));
      //  if (newDatabase.existsSync()) {
      //    log('file exist');
      //  } else {
      //    log('no');
      //  }
      //  final savePath = join(
      //    dwnPath.path,
      //    'bookmarkData_${DateTime.now().toString()}.db',
      //  );
      //  await newDatabase.copy(savePath);
      //}
    } catch (e) {
      throw Exception(e);
    }
  }
}
