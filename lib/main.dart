import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:favo/entry.dart';
import 'package:rive/rive.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(title: 'ログイン'),
        '/login': (context) => EntryPage(title: '新規登録'),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  //フォームキー（正規表現用）
  final _formKey = GlobalKey<FormState>();

  //キーボード用の変数
  final _mailAddress = TextEditingController();
  final _password = TextEditingController();

  //アニメーション用
  AnimationController _animationController;

  //Rive用アニメーション
  Artboard _riveArtboard;
  RiveAnimationController _riveController;

  //初期に読み込まれる関数
  @override
  void initState() {
    //アニメーションの元（時間設定など）
    _animationController = AnimationController(
      /// アニメーションを何秒掛けて行うかを設定します。
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    //呼び出し
    _animationController.forward();

    //Riveファイルを読み込む
    rootBundle.load('assets/star.riv').then(
      (data) async {
        final file = RiveFile();
        if (file.import(data)) {
          final artboard = file.mainArtboard;
          artboard
              .addController(_riveController = SimpleAnimation('Animation 1'));
          setState(() => _riveArtboard = artboard);
        }
      },
    );
    super.initState();
  }

  @override
  void discope() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        // Scaffold自体の背景色も透過に
        //backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  //横幅調整
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: <Widget>[
                      //位置調整(SingleChildScrollViewを使うと中央寄せが効かなくなる)
                      SizedBox(height: 200),
                      //タイトル
                      _titleAnimation(),
                      //位置調整
                      SizedBox(height: 100),
                      //メール
                      TextFormField(
                        //入力制限
                        controller: _mailAddress,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        autocorrect: true,
                        enableInteractiveSelection: true,
                        maxLength: 20,
                        //デザイン
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          // 外枠付きデザイン
                          filled: true,
                          // fillColorで指定した色で塗り潰し
                          fillColor: Colors.white,
                          labelText: "Email",
                          hintText: 'メールアドレスを入力してください',
                        ),
                        // 入力変化しても自動でチェックしない。trueにすると初期状態および入力が変化する毎に自動でvalidatorがコールされる
                        autovalidate: false,
                        validator: (value) {
                          const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                          final regExp = RegExp(pattern);
                          if (value.isEmpty) {
                            return 'メールアドレスを入力してください。';
                          } else if (value.indexOf(' ') >= 0 ||
                              value.trim() == '') {
                            return '空文字は受け付けていません。';
                          } else if (value.indexOf('　') >= 0 ||
                              value.trim() == '') {
                            return '空文字は受け付けていません。';
                          } else if (!regExp.hasMatch(value)) {
                            return 'メール形式が正しくありません';
                          }
                        },
                      ),
                      //位置調整
                      SizedBox(height: 40),
                      //パスワード
                      TextFormField(
                        //入力制限
                        controller: _password,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        autocorrect: false,
                        enableInteractiveSelection: false,
                        maxLength: 10,
                        //デザイン
                        decoration: const InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          border: OutlineInputBorder(),
                          // 外枠付きデザイン
                          filled: true,
                          // fillColorで指定した色で塗り潰し
                          fillColor: Colors.white,
                          labelText: "Password",
                          hintText: 'パスワードを入力してください',
                        ),
                        // 入力変化しても自動でチェックしない。trueにすると初期状態および入力が変化する毎に自動でvalidatorがコールされる
                        autovalidate: false,
                        //autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          String pattern1 =
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
                          String pattern2 = r'^(?=.*[!-/:-@\\[-`{-~]).{1,}$';
                          RegExp regExp1 = new RegExp(pattern1);
                          RegExp regExp2 = new RegExp(pattern2);

                          if (value.isEmpty) {
                            return 'パスワードを入力してください。';
                          } else if (value.indexOf(' ') >= 0 ||
                              value.trim() == '') {
                            return '空文字は受け付けていません。';
                          } else if (value.indexOf('　') >= 0 ||
                              value.trim() == '') {
                            return '空文字は受け付けていません。';
                          } else if (!regExp1.hasMatch(value)) {
                            return '大文字小文字数字を含めて８文字以上入力ください';
                          } else if (regExp2.hasMatch(value)) {
                            return '使用できない文字が含まれています';
                          }
                        },
                      ),
                      //位置調整
                      SizedBox(height: 60),
                      //ログインボタン
                      MaterialButton(
                        height: 70.0,
                        minWidth: 350.0,
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.green,
                        shape: const StadiumBorder(
                            //side: BorderSide(color: Colors.black),
                            ),
                        //押した時の処理
                        onPressed: () {
                          // バリデーションチェック
                          if (_formKey.currentState.validate()) {
                            //画面遷移
                            Navigator.of(context).pushNamed('/mypage');
                          }
                        },
                      ),
                      //位置調整
                      SizedBox(height: 40),
                      //新規ボタン
                      MaterialButton(
                        height: 70.0,
                        minWidth: 200.0,
                        child: Text(
                          "Sign up",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.black,
                        shape: const StadiumBorder(
                            //side: BorderSide(color: Colors.black),
                            ),
                        //押した時の処理
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                // 表示する画面のWidget
                                return EntryPage(title: '新規登録');
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                // 遷移時のアニメーションを指定
                                final Offset begin = Offset(0.0, 1.0);
                                final Offset end = Offset.zero;
                                final Tween<Offset> tween =
                                    Tween(begin: begin, end: end);
                                final Animation<Offset> offsetAnimation =
                                    animation.drive(tween);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //タイトルアニメーション
  Widget _titleAnimation() {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform(
                transform: _generateMatrix(_createAnimation(0)),
                child: Text(
                  'f',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              Transform(
                transform: _generateMatrix(_createAnimation(1)),
                child: Text(
                  'a',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              Transform(
                transform: _generateMatrix(_createAnimation(2)),
                child: Text(
                  'v',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              Transform(
                transform: _generateMatrix(_createAnimation(3)),
                child: Text(
                  'o',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              //画面遷移時、リセットされる
              SizedBox(

                // サイズが大きすぎたので調整する
                height: 90,
                width: 90,
                // Riveアニメーションの部分！
                child: Rive(artboard: _riveArtboard),
              ),
            ],
          );
        });
  }

  //遅延
  Animation _createAnimation(int delay) {
    assert(delay < 10);

    final actualDelay = 0.1 * delay;

    return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(actualDelay, 1.0, curve: Curves.fastOutSlowIn)));
  }

  //フェードインの開始位置
  Matrix4 _generateMatrix(Animation animation) {
    ////スタート位置
    final value = lerpDouble(2000, 0, animation.value);
    //向き(x軸、y軸、z軸)
    return Matrix4.translationValues(value, 0.0, 0.0);
  }
}