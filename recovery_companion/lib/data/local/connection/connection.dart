// Picks the right database connection for the platform at compile time, so
// web builds never try to compile the dart:io / SQLCipher native path.
export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.js_interop) 'web.dart';
