import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/secure_store.dart';

part 'secure_store_provider.g.dart';

/// App-wide secure storage wrapper.
@Riverpod(keepAlive: true)
SecureStore secureStore(SecureStoreRef ref) => SecureStore();
