import 'dart:io';
import 'package:favo/photo_repository.dart';
import 'package:favo/photo.dart';
import 'package:favo/providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favo/photo_view.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_riverpod/src/provider.dart';
import 'main.dart';

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
    _controller = PageController(
      initialPage: context.read(photoListIndexProvider).state,
    );
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
      body: PageView(
          controller: _controller,
          //表示が切り替わったとき
          onPageChanged: (int index) => _onPageChanged(index),
          children: [
            //[全ての画像]を表示する部分
            Consumer(
              builder: (context, watch, child) {
                //画像データ一覧を受け取る
                final asyncPhotoList = watch(photoListPvovider);
                return asyncPhotoList.when(
                  data: (List<Photo> photoList) {
                    return PhotoGridView(
                      //CloudFireStoreから取得した画像のURL一覧を渡す
                      photoList: photoList,
                      //コールバックを設定しタップした画像のURLを受け取る
                      onTap: (photo) => _onTapPhoto(photo, photoList),
                      //お気に入り登録
                      onTapFav: (photo) => _onTapFav(photo),
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
            //[お気に入り登録したが画像]を表示する部分
            Consumer(
              builder: (context, watch, child) {
                //画像データ一覧を受け取る
                final asyncPhotoList = watch(photoListPvovider);
                return asyncPhotoList.when(
                  data: (List<Photo> photoList) {
                    return PhotoGridView(
                      //CloudFireStoreから取得した画像のURL一覧を渡す
                      photoList: photoList,
                      //コールバックを設定しタップした画像のURLを受け取る
                      onTap: (photo) => _onTapPhoto(photo, photoList),
                      //お気に入り登録
                      onTapFav: (photo) => _onTapFav(photo),
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
          ]),
      //画像追加ボタン
      floatingActionButton: FloatingActionButton(
        //画像追加用ボタンを田尾応したときの処理
        onPressed: () => _onAddPhoto(),
        child: Icon(Icons.add),
      ),
      //ナビゲーションバー表示部分
      bottomNavigationBar: Consumer(
        builder: (context, watch, child) {
          //現在のページを受け取る
          final photoIndex = watch(photoListIndexProvider).state;
          return BottomNavigationBar(
            onTap: (int index) => _onTabBottunNavigationItem(index),
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.image), label: 'フォト'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'お気に入り'),
            ],
          );
        },
      ),
    );
  }

  //画像選択処理
  void _onTapPhoto(Photo photo, List<Photo> photoList) {
    final initialIndex = photoList.indexOf(photo);
    Navigator.of(context).push(MaterialPageRoute(
        //ProviderScopeを使いScopedProviderの値を上書きできる
        builder: (_) => ProviderScope(
              overrides: [
                photoViewInitialIndexProvider.overrideWithValue(initialIndex)
              ],
              child: PhotoViewPage(),
            )));
  }

  //画像追加処理
  Future<void> _onAddPhoto() async {
    //画像ファイルを選択
    final FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    //画像ファイルが選択された場合
    if (result != null) {
      final User user = FirebaseAuth.instance.currentUser;
      final PhotoRepository repository = PhotoRepository(user);
      final File file = File(result.files.single.path);
      await repository.addPhoto(file);
    }
  }

  //お気に入り登録処理
  Future<void> _onTapFav(Photo photo) async {
    final photoRepository = context.read(photoRepositoryProvider);
    final toggledPhoto = photo.toggleIsFavorite();
    await photoRepository.updatePhoto(toggledPhoto);
  }

  //ページ切り替え処理
  void _onPageChanged(int index) {
    //ページの値を更新する
    context.read(photoListIndexProvider).state = index;
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
    //ページの値を更新する
    context.read(photoListIndexProvider).state = index;
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
    this.photoList,
    this.onTap,
    this.onTapFav,
  }) : super(key: key);

  final List<Photo> photoList;
  final Function(Photo photo) onTap;
  final Function(Photo photo) onTapFav;

  @override
  Widget build(BuildContext context) {
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
      children: photoList.map((Photo photo) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              //Widgetをタップ可能にする
              child: InkWell(
                onTap: () => onTap(photo),
                //URLを指定して画像を表示
                child: Image.network(
                  photo.imageURL,
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
                onPressed: () => {
                  onTapFav(photo),
                },
                color: Colors.white,
                icon: Icon(
                  photo.isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
