import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favo/photo.dart';
import 'package:favo/photo_repository.dart';

final userProvider = StreamProvider.autoDispose((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

//ProviderからPhotoRepositoryを渡す
final photoRepositoryProvider = Provider.autoDispose((ref) {
  final user = ref.watch(userProvider).data.value;
  return user == null ? null : PhotoRepository(user);
});

//ref.watch()を使うことで他Providerのデータを取得できる
final photoListPvovider = StreamProvider.autoDispose((ref) {
  final photoRepository = ref.watch(photoRepositoryProvider);
  return photoRepository == null
      ? Stream.value(<Photo>[])
      : photoRepository.getPhotoList();
});

//photoListProviderのデータを元に、お気に入り登録されたデータのみ受け渡せるようにする
final favoritePhotoListProvider = Provider.autoDispose((ref) {
  return ref.watch(photoListPvovider).whenData(
    (List<Photo> data) {
      return data.where((photo) => photo.isFavorite == true).toList();
    },
  );
});

final photoListIndexProvider = StateProvider.autoDispose((ref) {
  return 0;
});

final photoViewInitialIndexProvider = ScopedProvider<int>(null);
