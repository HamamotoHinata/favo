import 'package:favo/providers.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:favo/photo.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_riverpod/src/provider.dart';
import 'main.dart';
import 'package:share/share.dart';

class PhotoViewPage extends StatefulWidget {
  PhotoViewPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      //Riverpodから初期値を受け取り設定
      initialPage: context.read(photoViewInitialIndexProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBarの裏までbodyの表示エリアを広げる
      extendBodyBehindAppBar: true,
      //透明なAppBarを作る
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          //画像一覧
          Consumer(
            builder: (context, watch, child) {
              //画像データ一覧を受け取る
              final asyncPhotoList = watch(photoListPvovider);
              return asyncPhotoList.when(
                data: (photoList) {
                  return PageView(
                    controller: _controller,
                    onPageChanged: (int index) => {},
                    children: photoList.map((Photo photo) {
                      return Image.network(
                        photo.imageURL,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  );
                },
                loading: () {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                error: (e, stackTrace) {
                  return Center(
                    child: Text(e.toString()),
                  );
                },
              );
            },
          ),
          //アイコンボタンを画像の手前に重ねる
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              //フッター部分にグラデーションを入れてみる
              decoration: BoxDecoration(
                //線形グラデーション
                gradient: LinearGradient(
                  //下方向から上方向に向かってグラデーションさせる
                  begin: FractionalOffset.bottomCenter,
                  end: FractionalOffset.topCenter,
                  //半透明の黒から透明にグラデーションさせる
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //共有ボタン
                  IconButton(
                    onPressed: () => {
                      _onTapShare(),
                    },
                    color: Colors.white,
                    icon: Icon(Icons.share),
                  ),
                  //削除ボタン
                  IconButton(
                    onPressed: () => {
                      _onTapDelete(),
                    },
                    color: Colors.white,
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //ログアウト
  Future<void> _onSignOut() async {
    //ログアウト処理
    await FirebaseAuth.instance.signOut();
    //現在の画面は不要になるのでpushReplacementを使う
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(title: 'ログイン'),
      ),
    );
  }

  //削除
  Future<void> _onTapDelete() async {
    final photoRepository = context.read(photoRepositoryProvider);
    final photoList = context.read(photoListPvovider).data.value;
    final photo = photoList[_controller.page.toInt()];

    if (photoList.length == 1) {
      Navigator.of(context).pop();
    } else if (photoList.last == photo) {
      await _controller.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    await photoRepository.deletePhoto(photo);
  }

  //シェア処理
  Future<void> _onTapShare() async {
    final photoList = context.read(photoListPvovider).data.value;
    final photo = photoList[_controller.page.toInt()];
    //画像URLを共有
    await Share.share(photo.imageURL);
  }
}
