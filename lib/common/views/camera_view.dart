import 'dart:io';
import 'dart:typed_data';
import 'package:absen/common/utils/extensions/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key, required this.onImage, required this.onInputImage})
      : super(key: key);

  final Function(Uint8List image) onImage;
  final Function(InputImage inputImage) onInputImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File? _image;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Dekatkan wajah Anda dilingkaran tersebut',
          style: TextStyle(
              color: Color.fromARGB(255, 3, 92, 103),
              fontFamily: 'fontku',
              fontWeight: FontWeight.bold),
        ),
        const Text(
          'Agar system mendapatkan hasil yang maksimal',
          style: TextStyle(
              color: Color.fromARGB(255, 3, 92, 103),
              fontFamily: 'fontku',
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 15,
        ),
        _image != null
            ? CircleAvatar(
                radius: 0.15.sh,
                backgroundColor: const Color.fromARGB(255, 7, 138, 175),
                backgroundImage: FileImage(_image!),
              )
            : CircleAvatar(
                radius: 0.15.sh,
                backgroundImage: const AssetImage('assets/big.gif'),
              ),
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: _getImage,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/tap2.png'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Column(
          children: [
            Text(
              "Tap untuk scan wajah",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 65, 177, 123),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future _getImage() async {
    setState(() {
      _image = null;
    });
    final pickedFile = await _imagePicker?.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
      maxHeight: 400,
      // imageQuality: 50,
    );
    if (pickedFile != null) {
      _setPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _setPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });

    Uint8List imageBytes = _image!.readAsBytesSync();
    widget.onImage(imageBytes);

    InputImage inputImage = InputImage.fromFilePath(path);
    widget.onInputImage(inputImage);
  }
}
