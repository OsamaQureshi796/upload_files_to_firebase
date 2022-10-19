import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MultiFileUplaodScreen extends StatefulWidget {
  const MultiFileUplaodScreen({Key? key}) : super(key: key);

  @override
  _MultiFileUplaodScreenState createState() => _MultiFileUplaodScreenState();
}

class _MultiFileUplaodScreenState extends State<MultiFileUplaodScreen> {
  List<File> images = [];

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload multiple files")),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 50,
            ),
            InkWell(
              onTap: () {
                getMultipImage();
              },
              child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Center(
                    child: Icon(
                      Icons.upload_file,
                      size: 50,
                    ),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: Get.width,
              height: 150,
              child: images.length == 0
                  ? Center(
                      child: Text("No Images found"),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, i) {
                        return Container(
                            width: 100,
                            margin: EdgeInsets.only(right: 10),
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8)),
                            child: Image.file(
                              images[i],
                              fit: BoxFit.cover,
                            ));
                      },
                      itemCount: images.length,
                    ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Your name'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: MaterialButton(
                color: Colors.blue,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                height: 50,
                onPressed: () async {
                  for (int i = 0; i < images.length; i++) {
                    String url = await uploadFile(images[i]);
                    downloadUrls.add(url);

                    if (i == images.length - 1) {
                      storeEntry(downloadUrls, nameController.text);
                    }
                  }
                },
                child: Text("Upload"),
              ),
            )
          ]),
        ),
      ),
    );
  }

  List<String> downloadUrls = [];

  final ImagePicker _picker = ImagePicker();

  getMultipImage() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null) {
      pickedImages.forEach((e) {
        images.add(File(e.path));
      });

      setState(() {});
    }
  }

  Future<String> uploadFile(File file) async {
    final metaData = SettableMetadata(contentType: 'image/jpeg');
    final storageRef = FirebaseStorage.instance.ref();
    Reference ref = storageRef
        .child('pictures/${DateTime.now().microsecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(file, metaData);

    final taskSnapshot = await uploadTask.whenComplete(() => null);
    String url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  storeEntry(List<String> imageUrls, String name) {
    FirebaseFirestore.instance
        .collection('story')
        .add({'image': imageUrls, 'name': name}).then((value) {
      Get.snackbar('Success', 'Data is stored successfully');
    });
  }
}
