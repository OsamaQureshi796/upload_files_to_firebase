import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cli_test/views/upload_multiple_files.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? myImage;

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Profile")),
      body: Container(
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          InkWell(
            onTap: () {
              openBottomSheet();
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
              onPressed: () {
                uploadFile();
              },
              child: Text("Upload"),
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
              onPressed: () {
                Get.to(() => MultiFileUplaodScreen());
              },
              child: Text("Multi File"),
            ),
          )
        ]),
      ),
    );
  }

  openBottomSheet() {
    Get.bottomSheet(Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      width: double.infinity,
      height: 150,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        buildImageWidget(
            iconData: Icons.camera_alt,
            onPressed: () {
              getImage(ImageSource.camera);
            }),
        buildImageWidget(
            iconData: Icons.image,
            onPressed: () {
              getImage(ImageSource.gallery);
            }),
      ]),
    ));
  }

  buildImageWidget({required IconData iconData, required Function onPressed}) {
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            iconData,
            size: 30,
          ),
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      myImage = File(image.path);

      setState(() {});
      Get.back();
    }
  }

  void uploadFile() async {
    final file = myImage!;
    final metaData = SettableMetadata(contentType: 'image/jpeg');
    final storageRef = FirebaseStorage.instance.ref();
    Reference ref = storageRef
        .child('pictures/${DateTime.now().microsecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(file, metaData);

    uploadTask.snapshotEvents.listen((event) {
      switch (event.state) {
        case TaskState.running:
          print("File is uploading");
          break;
        case TaskState.success:
          ref.getDownloadURL().then((value) {
            storeEntry(value, nameController.text);
          });
          break;
      }
    });
  }

  storeEntry(String imageUrl, String name) {
    FirebaseFirestore.instance
        .collection('users')
        .add({'image': imageUrl, 'name': name}).then((value) {
      Get.snackbar('Success', 'Data is stored successfully');
    });
  }
}
