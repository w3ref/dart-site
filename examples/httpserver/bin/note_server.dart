// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Client program is note_client.dart.
// Use note_taker.html to run the client.

import 'dart:convert' show utf8, json;
import 'dart:io';

const port = 4042;
const _noteFilePath = 'data/notes.txt';
int _count = 0;

Future<void> main() async {
  // One note per line.
  try {
    List<String> lines = File(_noteFilePath).readAsLinesSync();
    _count = lines.length;
  } on FileSystemException {
    print('Could not open $_noteFilePath.');
    return;
  }

  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Listening for requests on $port.');
  await _listenForRequests(server);
}

Future _listenForRequests(HttpServer requests) async {
  await for (HttpRequest request in requests) {
    switch (request.method) {
      case 'POST':
        await _handlePost(request);
        break;
      case 'OPTION':
        handleOptions(request);
        break;
      default:
        defaultHandler(request);
        break;
    }
  }
}

Future _handlePost(HttpRequest request) async {
  Map decoded;

  _addCorsHeaders(request.response);

  try {
    decoded =
        await utf8.decoder.bind(request).transform(json.decoder).first as Map;
  } catch (e) {
    print('Request listen error: $e');
    return;
  }

  if (decoded.containsKey('myNote')) {
    saveNote(request, "${decoded['myNote']}\n");
  } else {
    readNote(request, decoded['getNote'] as String);
  }
}

void saveNote(HttpRequest request, String myNote) {
  try {
    File(_noteFilePath).writeAsStringSync(myNote, mode: FileMode.append);
  } catch (e) {
    print("Couldn't open $_noteFilePath: $e");
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..writeln('Couldn\'t save note.')
      ..close();
    return;
  }

  _count++;
  request.response
    ..statusCode = HttpStatus.ok
    ..writeln('You have $_count notes.')
    ..close();
}

void readNote(HttpRequest request, String getNote) {
  final requestedNote = int.tryParse(getNote) ?? 0;
  if (requestedNote >= 0 && requestedNote < _count) {
    List<String> lines = File(_noteFilePath).readAsLinesSync();
    request.response
      ..statusCode = HttpStatus.ok
      ..writeln(lines[requestedNote])
      ..close();
  }
}

void defaultHandler(HttpRequest request) {
  final response = request.response;
  _addCorsHeaders(response);
  response
    ..statusCode = HttpStatus.notFound
    ..write('Not found: ${request.method}, ${request.uri.path}')
    ..close();
}

void handleOptions(HttpRequest request) {
  final response = request.response;
  _addCorsHeaders(response);
  print('${request.method}: ${request.uri.path}');
  response
    ..statusCode = HttpStatus.noContent
    ..close();
}

// #docregion addCorsHeaders
void _addCorsHeaders(HttpResponse response) {
  response.headers.add('Access-Control-Allow-Origin', '*');
  response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.headers.add('Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept');
}
