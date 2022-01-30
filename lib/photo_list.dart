import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:favo/photo_view.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoListPage extends StatefulWidget {
  PhotoListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PhotoListPageState createState() => _PhotoListPageState();
}

class _PhotoListPageState extends State<PhotoListPage> {
  int _currentIndex;
  PageController _controller;

  @override
  void initState() {
    super.initState();
    //PageViewで表示されているWidgetの番号を貼っておく
    _currentIndex = 0;
    //PageViewの切り替えで使う
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    //ログインしているユーザーの情報
    final User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => {
              _onSignOut(),
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          //CloudFireStoreからデータを取得
          stream: FirebaseFirestore.instance
              .collection('users/${user.uid}/photos')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            //CloudFireStoreからデータを取得中
            if (snapshot.hasData == false) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            //データ取得完了
            final QuerySnapshot query = snapshot.data;
            //画像のURL一覧を作成
            final List<String> imageList =
                query.docs.map((doc) => doc.get('imageURL') as String).toList();
            return PageView(
              controller: _controller,
              //表示が切り替わったとき
              onPageChanged: (int index) => _onPageChanged(index),
              children: [
                //[全ての画像]を表示する部分
                PhotoGridView(
                  //CloudFireStoreから取得した画像のURL一覧を渡す
                  imageList: imageList,
                  //コールバックを設定しタップした画像のURLを受け取る
                  onTap: (imageURL) => _onTapPhoto(imageURL, imageList),
                ),
                //[お気に入り登録したが画像]を表示する部分
                PhotoGridView(
                  imageList: [],
                  //コールバックを設定しタップした画像のURLを受け取る
                  onTap: (imageURL) => _onTapPhoto(imageURL, imageList),
                ),
              ],
            );
          }),
      //画像追加ボタン
      floatingActionButton: FloatingActionButton(
        //画像追加用ボタンを田尾応したときの処理
        onPressed: () => _onAddPhoto(),
        child: Icon(Icons.add),
      ),
      //ナビゲーションバー表示部分
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => _onTabBottunNavigationItem(index),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'フォト'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
        ],
      ),
    );
  }

  //画像追加処理
  Future<void> _onAddPhoto() async {
    //画像ファイルを選択
    final FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    //画像ファイルが選択された場合
    if (result != null) {
      //ログイン中のユーザー情報を取得
      final User user = FirebaseAuth.instance.currentUser;
      //フォルダとファイル名を指定し画像ファイルをアップロード
      final int timestamp = DateTime.now().microsecondsSinceEpoch;
      final File file = await File(result.files.single.path);
      final String name = file.path.split('/').last;
      final String path = '${timestamp}_$name';
      final TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/photos')
          .child(path)
          .putFile(file);

      //アップロードした画像のURLを取得
      final String imageURL = await task.ref.getDownloadURL();
      //アップロードした画像の保存先を取得
      final String imagePath = task.ref.fullPath;
      //データ
      final data = {
        'imageURL': imageURL,
        'imagePath': imagePath,
        'isFavorite': false,
        'createdAt': Timestamp.now(),
      };
      //データをCloud Firestoreに保存
      await FirebaseFirestore.instance
          .collection('users/${user.uid}/photos')
          .doc()
          .set(data);
    }
  }

  //ページ切り替え処理
  void _onPageChanged(int index) {
    //Widgetの番号を更新
    setState(() {
      _currentIndex = index;
    });
  }

  //ナビゲーションバーの処理
  void _onTabBottunNavigationItem(int index) {
    //PageViewで表示するWidgetを切り替える
    _controller.animateToPage(
        //表示するWidgetの番号
        //1,全ての画像、　2,お気に入り登録した画像
        index,
        //表示を切り替える時にかかる時間
        duration: Duration(milliseconds: 300),
        //アニメーションの動き
        curve: Curves.easeIn);
    //PageViewで表示されているWidgetの番号を更新
    setState(() {
      _currentIndex = index;
    });
  }

  //画面遷移
  void _onTapPhoto(String imageURL, List<String> imageList) {
    // 最初に表示する画像のURLをして、画像詳細画面に切り替える
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewPage(
          imageURL: imageURL,
          imageList: imageList,
        ),
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

class PhotoGridView extends StatelessWidget {
  const PhotoGridView({
    Key key,
    this.imageList,
    this.onTap,
  }) : super(key: key);

  final List<String> imageList;

  //コールバックからタップされた画像のURLを受け渡す
  final Function(String imageURL) onTap;

  @override
  Widget build(BuildContext context) {
    final List<String> imageList = [
      //画像
    ];

    //GridViewを使いタイル状にWidgetを表示する
    return GridView.count(
      //１行あたりに表示するWidgetの数
      crossAxisCount: 2,
      //Widget間のスペース（上下）
      mainAxisSpacing: 8,
      //Widget間のスペース（右左）
      crossAxisSpacing: 8,
      //全体の余白
      padding: const EdgeInsets.all(8),
      //画像一覧
      children: imageList.map((String imageURL) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              //Widgetをタップ可能にする
              child: InkWell(
                onTap: () => onTap(imageURL),
                //URLを指定して画像を表示
                child: Image.network(
                  imageURL,
                  //画像の表示の仕方を調整できる
                  //比率を維持しつつ余白がが出ないようにするのでcoverを指定
                  fit: BoxFit.cover,
                ),
              ),
            ),
            //画像の上にお気に入りアイコンを重ねて表示
            //Alignment.topRightを指定し右上部分にアイコンを表示
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => {},
                color: Colors.white,
                icon: Icon(Icons.favorite_border),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
