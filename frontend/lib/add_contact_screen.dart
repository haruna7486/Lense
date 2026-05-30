import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ユーザーが文字を入力するので StatefulWidget に変更
class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  // 専門用語解説：TextEditingController（テキスト・エディティング・コントローラー）
  // ユーザーが入力した文字をリアルタイムで監視・取得するためのFlutterの便利な道具です。
  final brandController = TextEditingController();
  final colorController = TextEditingController();
  final diaController = TextEditingController();
  final graphicDiaController = TextEditingController();
  final bcController = TextEditingController();

  // 🔴 PythonのAPIにデータを送って登録する関数
  Future<void> registerContact() async {
    final url = Uri.parse('http://127.0.0.1:8000/contacts/');

    // POSTリクエストを送る
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      // 入力された文字をJSON（Pythonが読める形）に翻訳して送る
      body: json.encode({
        'brand_name': brandController.text,
        'color_name': colorController.text,
        // 数字は小数点（double）に変換。空っぽの場合はデフォルト値を入れる
        'dia': double.tryParse(diaController.text) ?? 14.0,
        'graphic_dia': double.tryParse(graphicDiaController.text) ?? 13.0,
        'base_curve': double.tryParse(bcController.text) ?? 8.6,
      }),
    );

    // 200は「成功」の合図
    if (response.statusCode == 200) {
      if (mounted) {
        // 成功したら、現在の画面（登録画面）を閉じて一覧に戻る
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいカラコンを登録'),
        backgroundColor: Colors.pink[100],
      ),
      // SingleChildScrollView：キーボードが出た時に画面がスクロールできるようにする
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: 'ブランド名 (例: HapaKristin)',
              ),
            ),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: 'カラー名 (例: Secretive Kristin)',
              ),
            ),
            TextField(
              controller: diaController,
              decoration: const InputDecoration(labelText: 'DIA (例: 14.2)'),
              keyboardType: TextInputType.number, // 数字キーボードを出す設定
            ),
            TextField(
              controller: graphicDiaController,
              decoration: const InputDecoration(labelText: '着色直径 (例: 13.0)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bcController,
              decoration: const InputDecoration(labelText: 'BC (例: 8.6)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30), // 少し隙間を空ける
            // 登録ボタン
            SizedBox(
              width: double.infinity, // ボタンの幅を横いっぱいに広げる
              height: 50,
              child: ElevatedButton(
                onPressed: registerContact, // 押した時に上の registerContact 関数を呼ぶ
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '登録する',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
