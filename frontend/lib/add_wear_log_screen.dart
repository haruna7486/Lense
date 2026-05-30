import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // 👈 追加（Webかどうかを判定するツール）

class AddWearLogScreen extends StatefulWidget {
  final int contactId;

  const AddWearLogScreen({super.key, required this.contactId});

  @override
  State<AddWearLogScreen> createState() => _AddWearLogScreenState();
}

class _AddWearLogScreenState extends State<AddWearLogScreen> {
  XFile? _pickedFile; // Fileではなく、Webにも対応した「XFile」に変更

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('装着記録を追加'),
        backgroundColor: Colors.pink[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ここをWeb対応に変更
            _pickedFile != null
                ? (kIsWeb // もし今Chrome(Web)で動かしているなら…
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
            // ここまで
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('カメラロールから選ぶ', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
