import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_contact_screen.dart';
import 'add_wear_log_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LenseLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// 画面が動的に変わるように StatefulWidget に変更
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List contacts = []; // カラコンのデータを入れる空のリスト

  @override
  void initState() {
    super.initState();
    fetchContacts(); // 画面が開いた瞬間にデータを取得する
  }

  // 🔴 PythonのAPIからデータを取ってくる関数
  Future<void> fetchContacts() async {
    // さっき作った一覧取得のURLにアクセス
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/contacts/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        // 返ってきたデータをFlutterで使える形に翻訳してリストに入れる
        contacts = json.decode(utf8.decode(response.bodyBytes));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LenseLog (カラコン記録)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // データが空ならロード中のぐるぐるを表示、データがあればリストを表示
      body: contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: const Icon(Icons.remove_red_eye, color: Colors.pink),
                  title: Text(
                    '${contact['brand_name']} - ${contact['color_name']}',
                  ),
                  subtitle: Text(
                    'DIA: ${contact['dia']} / BC: ${contact['base_curve']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_a_photo, color: Colors.grey),
                    onPressed: () {
                      // カメラアイコンを押したら、装着記録画面へ移動する（カラコンのIDを渡す）
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddWearLogScreen(contactId: contact['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigatorを使って、新しい画面（AddContactScreen）へ移動する
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContactScreen()),
          );

          // 登録画面から戻ってきたら、自動で最新のデータを読み込み直す
          fetchContacts();
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
