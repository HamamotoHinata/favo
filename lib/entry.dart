import 'package:favo/photo_list.dart';
import 'package:flutter/material.dart';
import 'package:favo/main.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';

class EntryPage extends StatefulWidget {
  EntryPage({Key key}) : super(key: key);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage>
    with SingleTickerProviderStateMixin {
  //フォームキー（正規表現用）
  final _formKey = GlobalKey<FormState>();

  //キーボード用の変数
  final _userName = TextEditingController();
  final _mailAddress = TextEditingController();
  final _password = TextEditingController();
  final _checkPassword = TextEditingController();

  //パスワード用変数
  String password = '';
  String check = '';

  //アニメーション用
  AnimationController _animationController;

  //初期に読み込まれる関数
  @override
  void initState() {
    super.initState();
    //アニメーションの元（時間設定など）
    _animationController = AnimationController(
      /// アニメーションを何秒掛けて行うかを設定します。
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    //呼び出し
    _animationController.forward();
  }

  @override
  void discope() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraint) {
      final height = contraint.maxHeight;
      final width = contraint.maxWidth;
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(children: <Widget>[
          Container(
            color: Colors.white,
          ),
          //下のサークル
          Positioned(
            top: height * 0.54,
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.pinkAccent.withOpacity(0.3)),
            ),
          ),
          Scaffold(
            // Scaffold自体の背景色も透過に
            backgroundColor: Colors.transparent,
            body: Form(
              key: _formKey,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: <Widget>[
                          //位置調整(SingleChildScrollViewを使うと中央寄せが効かなくなる)
                          SizedBox(height: 70),
                          //タイトル
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 70,
                            ),
                          ),
                          SizedBox(height: 50),
                          _inputAnimation(),
                          //位置調整
                          SizedBox(height: 70),
                          _buttonAnimation(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }

  //アカウント登録時にチェックするメソッド
  Future<void> _singUp() async {
    try {
      // バリデーションチェック
      if (_formKey.currentState.validate() != true) {
        return;
      }
      //メールアドレス・パスワードをAuthenticationに新規登録
      final email = _mailAddress.text;
      final password = _checkPassword.text;
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      //登録完了のお知らせ
      await showDialog(
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
                              "ユーザー登録完了しました！",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        //サイズ調整
                        SizedBox(
                          height: 20,
                        ),
                        //rive
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: RiveAnimation.asset(
                            'assets/check_marker.riv',
                            animations: const ['Animation 1'],
                          ),
                        ),
                        //サイズ調整
                        SizedBox(
                          height: 20,
                        ),
                        //okボタン
                        MaterialButton(
                          height: 60.0,
                          minWidth: 200.0,
                          child: Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.red,
                          shape: const StadiumBorder(
                            //side: BorderSide(color: Colors.black),
                          ),
                          //押した時の処理
                          onPressed: () {
                            //画面遷移(現在の画面を削除して、新しく画面を追加する)
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => PhotoListPage(title: 'Photo List'),
                              ),
                            );
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
      );
    } catch (e) {
      //失敗したら
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("エラー"),
              content: Text(e.toString()),
            );
          });
    }
  }

  //入力フォーム用アニメーション
  Widget _inputAnimation() {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //名前
              Transform(
                transform: _sideMatrix(_createAnimation(0)),
                child: TextFormField(
                  //入力制限
                  controller: _userName,
                  obscureText: false,
                  autocorrect: true,
                  enableInteractiveSelection: true,
                  maxLength: 10,
                  //デザイン
                  decoration: const InputDecoration(
                    icon: Icon(Icons.account_circle),
                    border: OutlineInputBorder(),
                    // 外枠付きデザイン
                    filled: true,
                    // fillColorで指定した色で塗り潰し
                    fillColor: Colors.white,
                    labelText: "User Name",
                    hintText: '名前を入力してください',
                  ),
                  // 入力変化しても自動でチェックしない。trueにすると初期状態および入力が変化する毎に自動でvalidatorがコールされる
                  //バリテーションチェック
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'テキストを入力してください。';
                    } else if (value.indexOf(' ') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (value.indexOf('　') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    }
                  },
                ),
              ),
              //位置調整
              SizedBox(height: 30),
              //メール
              Transform(
                transform: _sideMatrix(_createAnimation(2)),
                child: TextFormField(
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
                  validator: (value) {
                    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                    final regExp = RegExp(pattern);
                    if (value.isEmpty) {
                      return 'メールアドレスを入力してください。';
                    } else if (value.indexOf(' ') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (value.indexOf('　') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (!regExp.hasMatch(value)) {
                      return 'メール形式が正しくありません';
                    }
                  },
                ),
              ),
              //位置調整
              SizedBox(height: 30),
              //パスワード
              Transform(
                transform: _sideMatrix(_createAnimation(4)),
                child: TextFormField(
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
                  validator: (value) {
                    String pattern1 =
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
                    String pattern2 = r'^(?=.*[!-/:-@\\[-`{-~]).{1,}$';
                    RegExp regExp1 = new RegExp(pattern1);
                    RegExp regExp2 = new RegExp(pattern2);

                    if (value.isEmpty) {
                      return 'パスワードを入力してください。';
                    } else if (value.indexOf(' ') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (value.indexOf('　') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (!regExp1.hasMatch(value)) {
                      return '大文字小文字数字を含めて８文字以上入力ください';
                    } else if (regExp2.hasMatch(value)) {
                      return '使用できない文字が含まれています';
                    }
                  },
                ),
              ),
              //位置調整
              SizedBox(height: 30),
              //パスワード(確認用)
              Transform(
                transform: _sideMatrix(_createAnimation(6)),
                child: TextFormField(
                  //入力制限
                  controller: _checkPassword,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  autocorrect: false,
                  enableInteractiveSelection: false,
                  maxLength: 10,
                  //デザイン
                  decoration: const InputDecoration(
                    icon: Icon(Icons.done),
                    border: OutlineInputBorder(),
                    // 外枠付きデザイン
                    filled: true,
                    // fillColorで指定した色で塗り潰し
                    fillColor: Colors.white,
                    labelText: "Check Password",
                    hintText: 'もう一度パスワードを入力してください',
                  ),
                  validator: (value) {
                    setState(() {
                      password = _password.text;
                      check = _checkPassword.text;
                    });
                    if (value.isEmpty) {
                      return 'テキストを入力してください。';
                    } else if (value.indexOf(' ') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (value.indexOf('　') >= 0 || value.trim() == '') {
                      return '空文字は受け付けていません。';
                    } else if (password != check) {
                      return 'パスワードが違います';
                    }
                  },
                ),
              ),
            ],
          );
        });
  }

  //ボタン用アニメーション
  Widget _buttonAnimation() {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //ログインボタン
              Transform(
                transform: _belowMatrix(_createAnimation(7)),
                child: MaterialButton(
                  height: 70.0,
                  minWidth: 350.0,
                  child: Text(
                    "Sing Up",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.pinkAccent,
                  shape: const StadiumBorder(
                      //side: BorderSide(color: Colors.black),
                      ),
                  //押した時の処理
                  onPressed: () => _singUp(),
                ),
              ),
              //位置調整
              SizedBox(height: 40),
              //戻るボタン
              Transform(
                transform: _belowMatrix(_createAnimation(8)),
                child: MaterialButton(
                  height: 70.0,
                  minWidth: 200.0,
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.black,
                  shape: const StadiumBorder(
                      //side: BorderSide(color: Colors.black),
                      ),
                  //押した時の処理
                  onPressed: () {
                    //画面遷移
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          // 表示する画面のWidget
                          return LoginPage();
                        },
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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

  //フェードインの開始位置（横）
  Matrix4 _sideMatrix(Animation animation) {
    final value = lerpDouble(500.0, 0, animation.value);
    //スタート位置
    return Matrix4.translationValues(value, 0.0, 0.0);
  }

  //フェードインの開始位置（下）
  Matrix4 _belowMatrix(Animation animation) {
    final value = lerpDouble(500.0, 0, animation.value);
    //スタート位置
    return Matrix4.translationValues(0.0, value, 0.0);
  }
}
