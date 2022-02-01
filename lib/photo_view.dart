import 'package:favo/providers.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:favo/photo.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_riverpod/src/provider.dart';
import 'package:share/share.dart';
import 'package:rive/rive.dart';

class PhotoViewPage extends StatefulWidget {
  PhotoViewPage({Key key}) : super(key: key);

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
                    //onPageChanged: (int index) => {},
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
              decoration: BoxDecoration(),
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
                      showDialog(
                        context: context,
                        builder: (_) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: AlertDialog(
                              //角丸
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0))),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        //テキスト
                                        Text(
                                          "\n"
                                          "削除しますか？",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        //rive
                                        SizedBox(
                                          height: 250,
                                          width: 250,
                                          child: RiveAnimation.asset(
                                          'assets/alert_icon.riv',
                                          animations: const ['show'],
                                          ),
                                        ),
                                        //okボタン
                                        MaterialButton(
                                          height: 60.0,
                                          minWidth: 200.0,
                                          child: Text(
                                            "OK",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: Colors.red,
                                          shape: const StadiumBorder(
                                              //side: BorderSide(color: Colors.black),
                                              ),
                                          //押した時の処理
                                          onPressed: () {
                                            _onTapDelete();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        //位置調整
                                        SizedBox(height: 30),
                                        //Cancelボタン
                                        MaterialButton(
                                          height: 60.0,
                                          minWidth: 200.0,
                                          child: Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: Colors.black,
                                          shape: const StadiumBorder(
                                              //side: BorderSide(color: Colors.black),
                                              ),
                                          //押した時の処理
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
