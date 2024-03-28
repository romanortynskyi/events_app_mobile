import 'dart:io';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class MultipartFileUtils {
  static MultipartFile getMultipartFile(File file, String field) {
    var byteData = file.readAsBytesSync();

    String mimeType = lookupMimeType(file.path) ?? '';
    String extension = path.extension(file.path);

    var multipartFile = MultipartFile.fromBytes(
      field,
      byteData,
      filename: '${DateTime.now()}.$extension',
      contentType: MediaType(
        mimeType.split('/')[0],
        mimeType.split('/')[1],
      ),
    );

    return multipartFile;
  }
}
