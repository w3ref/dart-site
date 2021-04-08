// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A server built using dart:io that serves the same file for all requests.
/// Visit http://localhost:4044 into your browser.
// #docregion
import 'dart:io' show InternetAddress, File, ContentType, HttpHeaders;

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';

const port = 4044;
final targetFile = File('web/index.html');

Future<void> main() async {
  Response handler(Request req) {
    if (targetFile.existsSync()) {
      print("Serving ${targetFile.path}.");

      return Response.ok(
        targetFile.openRead(),
        headers: {HttpHeaders.contentTypeHeader: ContentType.html.toString()},
      );
    }
    print("Can't open ${targetFile.path}.");

    return Response.notFound('not found');
  }

  await io.serve(handler, InternetAddress.loopbackIPv4, port);
}
