import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({
    Key key,
    this.imageURL,
    this.imageList,
  }) : super(key: key);

  //最初に表示する画像のURLを受け取る
  final String imageURL;

  //引数から画像のURLを受け取る
  final List<String> imageList;

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  PageController _controller;
  final List<String> imageList = [
    //画像
  ];

  @override
  void initState() {
    super.initState();

    final int initialPage = widget.imageList.indexOf(widget.imageURL);
    _controller = PageController(
      initialPage: initialPage,
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
          PageView(
            controller: _controller,
            onPageChanged: (int index) => {},
            children: widget.imageList.map((String imageURL) {
              return Image.network(
                imageURL,
                fit: BoxFit.cover,
              );
            }).toList(),
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
                    onPressed: () => {},
                  ),
                  //削除ボタン
                  IconButton(
                    onPressed: () => {},
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
}
