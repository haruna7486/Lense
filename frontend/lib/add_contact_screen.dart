import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final brandController = TextEditingController();
  final colorController = TextEditingController();
  final diaController = TextEditingController();
  final graphicDiaController = TextEditingController();
  final bcController = TextEditingController();

  Future<void> registerContact() async {
    final url = Uri.parse('http://127.0.0.1:8000/contacts/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'brand_name': brandController.text,
        'color_name': colorController.text,
        'dia': double.tryParse(diaController.text) ?? 14.0,
        'graphic_dia': double.tryParse(graphicDiaController.text) ?? 13.0,
        'base_curve': double.tryParse(bcController.text) ?? 8.6,
      }),
    );

    if (response.statusCode == 200) {
      if (mounted) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'ブランド名'),
            ),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: 'カラー名'),
            ),
            TextField(
              controller: diaController,
              decoration: const InputDecoration(labelText: 'DIA'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: graphicDiaController,
              decoration: const InputDecoration(labelText: '着色直径'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bcController,
              decoration: const InputDecoration(labelText: 'BC'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: registerContact,
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
