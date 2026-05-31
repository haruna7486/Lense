import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // 👈 追加：通信用のツール

class AddWearLogScreen extends StatefulWidget {
  final int contactId;

  const AddWearLogScreen({super.key, required this.contactId});

  @override
  State<AddWearLogScreen> createState() => _AddWearLogScreenState();
}

class _AddWearLogScreenState extends State<AddWearLogScreen> {
  XFile? _pickedFile;
  final memoController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  // 🔴 Pythonへ写真とメモを送信して保存する関数
  Future<void> _saveLog() async {
    if (_pickedFile == null) {
      // 写真が選ばれていない時は画面下部にメッセージを出してストップ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('写真を選択してください！')));
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/wear_logs/');

    // フォームデータ（写真＋文字）を送るためのリクエストを作成
    final request = http.MultipartRequest('POST', url);

    // ① 文字データをセットする
    request.fields['contact_id'] = widget.contactId.toString();
    request.fields['memo'] = memoController.text;

    // ② 画像データをセットする（Webでもスマホでも動くようにバイトデータとして読み込む）
    final bytes = await _pickedFile!.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: _pickedFile!.name,
    );
    request.files.add(multipartFile);

    // サーバーに送信！
    final response = await request.send();

    if (response.statusCode == 200) {
      if (mounted) {
        // 成功したらメッセージを出して、前の画面（一覧）に戻る
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('装着記録を保存しました！🎉')));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存に失敗しました。内容を確認してください。')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('装着記録を追加'),
        backgroundColor: Colors.pink[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _pickedFile != null
                ? (kIsWeb
                      ? Image.network(
                          _pickedFile!.path,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_pickedFile!.path),
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ))
                : Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('カメラロールから選ぶ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: '今日の着け心地や感想メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveLog, // 👈 修正した関数を呼び出す
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '記録を保存する',
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
