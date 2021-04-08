// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A static file server, serving files from the web directory.
/// Launch from the package root directory.
/// Visit http://localhost:4048 into your browser.
// #docregion
import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

const port = 4048;

Future<void> main() async {
  var handler = createStaticHandler(
    'web',
    defaultDocument: 'index.html',
  );

  await io.serve(handler, InternetAddress.loopbackIPv4, port);
  print('Listening on port 4048');
}
