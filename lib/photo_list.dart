import 'package:flutter/material.dart';
import 'package:favo/photo_view.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => {},
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
          PhotoGridView(
            //コールバックを設定しタップした画像のURLを受け取る
            onTap: (imageURL) => _onTapPhoto(imageURL),
          ),
          //[お気に入り登録したが画像]を表示する部分
          PhotoGridView(
            //コールバックを設定しタップした画像のURLを受け取る
            onTap: (imageURL) => _onTapPhoto(imageURL),
          ),
        ],
      ),
      //画像追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        child: Icon(Icons.add),
      ),
      //ナビゲーションバー表示部分
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => _onTabBottunNavigationItem(index),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'フォト'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'お気に入り'
          ),
        ],
      ),
    );
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
    //PageViewで表示づるWidgetを切り替える
    _controller.animateToPage(
      //表示するWidgetの番号
      //1,全ての画像、　2,お気に入り登録した画像
      index,
      //表示を切り替える時にかかる時間
      duration: Duration(milliseconds: 300),
      //アニメーションの動き
      curve: Curves.easeIn
    );
    //PageViewで表示されているWidgetの番号を更新
    setState(() {
      _currentIndex = index;
    });
  }

  //画面遷移
  void _onTapPhoto(String imageURL) {
    // 最初に表示する画像のURLをして、画像詳細画面に切り替える
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewPage(imageURL: imageURL),
      ),
    );
  }
}

class PhotoGridView extends StatelessWidget {
  const PhotoGridView({
    Key key,
    this.onTap,
  }) : super(key: key);

  //コールバックからタップされた画像のURLを受け渡す
  final void Function(String imageURL) onTap;

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
      children: imageList.map((String imageURL){
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
