import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:favo/photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//リポジトリ
class PhotoRepository {
  PhotoRepository(this.user);

  final User user;

  Stream<List<Photo>> getPhotoList() {
    return FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_queryToPhotoList);
  }

  Future<void> addPhoto(File file) async {
    //フォルダとファイル名を指定し画像ファイルをアップロード
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final String name = file.path.split('/').last;
    final String path = '${timestamp}_$name';
    final TaskSnapshot task = await FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/photos')
        .child(path)
        .putFile(file);

    final String imageURL = await task.ref.getDownloadURL();
    final String imagePath = task.ref.fullPath;
    final Photo photo = Photo(
      imageURL: imageURL,
      imagePath: imagePath,
      isFavorite: false,
    );

    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc()
        .set(_phototoMap(photo));
  }

  Future<void> deletePhoto(Photo photo) async {
    //Cloud FireStoreからデータを削除
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc(photo.id)
        .delete();
    //Storageの画像ファイルを削除
    await FirebaseStorage.instance.ref().child(photo.imagePath).delete();
  }

  Future<void> updatePhoto(Photo photo) async {
    //お気に入り登録状況のデータを更新
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc(photo.id)
        .update(_phototoMap(photo));
    //Storageの画像ファイルを削除
    await FirebaseStorage.instance.ref().child(photo.imagePath).delete();
  }

  List<Photo> _queryToPhotoList(QuerySnapshot query) {
    return query.docs.map((doc) {
      return Photo(
        id: doc.id,
        imageURL: doc.get('imageURL'),
        imagePath: doc.get('imagePath'),
        isFavorite: doc.get('isFavorite'),
        createdAt: (doc.get('createdAt') as Timestamp).toDate(),
      );
    }).toList();
  }

  Map<String, dynamic> _phototoMap(Photo photo) {
    return {
      'imageURL': photo.imageURL,
      'imagePath': photo.imagePath,
      'isFavorite': photo.isFavorite,
      'createdAt': photo.createdAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(photo.createdAt)
    };
  }
}
