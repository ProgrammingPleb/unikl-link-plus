import 'package:async/async.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

Future<Digest> getFileSha256(String path) async {
  final reader = ChunkedStreamReader(File(path).openRead());
  const chunkSize = 4096;
  var output = AccumulatorSink<Digest>();
  var input = sha256.startChunkedConversion(output);

  try {
    while (true) {
      final chunk = await reader.readChunk(chunkSize);
      if (chunk.isEmpty) {
        break;
      }
      input.add(chunk);
    }
  } finally {
    reader.cancel();
  }

  input.close();

  return output.events.single;
}
