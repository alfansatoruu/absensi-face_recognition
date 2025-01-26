import 'dart:developer';
import 'package:absen/common/utils/custom_snackbar.dart';
import 'package:absen/common/utils/custom_text_field.dart';
import 'package:absen/common/utils/custome_text_field3.dart';
import 'package:absen/common/views/custom_button.dart';
import 'package:absen/constants/theme.dart';
import 'package:absen/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EnterDetailsView extends StatefulWidget {
  final String image;
  final FaceFeatures? faceFeatures;

  const EnterDetailsView({
    super.key,
    required this.image,
    required this.faceFeatures,
  });

  @override
  State<EnterDetailsView> createState() => _EnterDetailsViewState();
}

class _EnterDetailsViewState extends State<EnterDetailsView> {
  final _formFieldKey = GlobalKey<FormFieldState>();
  final _formFieldKey2 = GlobalKey<FormFieldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  bool _isLoading = false;
  bool _isFaceDetected = false;

  String? _selectedProgram;
  int? _selectedSemester;

  final List<String> _programs = [
    'Ilmu Komputer',
    'Farmasi',
    'Desain Komunikasi Visual',
    'Bahasa Inggris',
    'Teknologi Informasi',
  ];

  final List<int> _semesters = List.generate(8, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _checkFaceDetection();
  }

  void _checkFaceDetection() {
    if (widget.faceFeatures == null ||
        !_isValidFaceFeatures(widget.faceFeatures!)) {
      setState(() {
        _isFaceDetected = false;
      });
      CustomSnackBar.errorSnackBar(
          "Wajah tidak terdeteksi! Silakan ambil ulang foto dengan wajah yang jelas.");
    } else {
      setState(() {
        _isFaceDetected = true;
      });
    }
  }

  bool _isValidFaceFeatures(FaceFeatures features) {
    // ignore: unnecessary_null_comparison
    return features.rightEye != null &&
        // ignore: unnecessary_null_comparison
        features.leftEye != null &&
        // ignore: unnecessary_null_comparison
        features.noseBase != null &&
        // ignore: unnecessary_null_comparison
        features.rightMouth != null &&
        // ignore: unnecessary_null_comparison
        features.leftMouth != null;
  }

  Future<void> _showExistingUserDialog(String message, String existingData) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Sudah Terdaftar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 8),
            Text(
              existingData,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkExistingUser(String name, String nim, String image) async {
    try {
      if (name.isEmpty || nim.isEmpty || image.isEmpty) {
        CustomSnackBar.errorSnackBar("Data input tidak lengkap!");
        return true;
      }

      if (!_isFaceDetected) {
        CustomSnackBar.errorSnackBar(
            "Wajah tidak terdeteksi! Silakan ambil ulang foto.");
        return true;
      }

      final nimQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("nim", isEqualTo: nim.trim().toUpperCase())
          .get();

      if (nimQuery.docs.isNotEmpty) {
        try {
          final existingUser = nimQuery.docs.first.data();

          // ignore: unnecessary_null_comparison
          if (existingUser != null && existingUser['name'] != null) {
            await _showExistingUserDialog(
                'NIM ini telah terdaftar dengan data berikut:',
                'Nama: ${existingUser['name']}');
            return true;
          }
        } catch (e) {
          log("Error processing NIM query data: $e");
        }
      }

      try {
        final allUsers =
            await FirebaseFirestore.instance.collection("users").get();

        for (var doc in allUsers.docs) {
          final userData = doc.data();

          if (userData['faceFeatures'] != null &&
              widget.faceFeatures != null &&
              _compareFaceFeatures(widget.faceFeatures!,
                  FaceFeatures.fromJson(userData['faceFeatures']))) {
            await _showExistingUserDialog(
                'Wajah ini telah terdaftar dengan data berikut:',
                'Nama: ${userData['name']}\nNIM: ${userData['nim']}');
            return true;
          }
        }
      } catch (e) {
        log("Error checking face features: $e");
      }

      return false;
    } catch (e) {
      log("Error checking existing user: $e");
      if (e is FirebaseException) {
        CustomSnackBar.errorSnackBar(
            "Kesalahan koneksi ke database: ${e.message}");
      } else {
        CustomSnackBar.errorSnackBar(
            "Terjadi kesalahan saat memeriksa data. Silakan coba lagi.");
      }
      return true;
    }
  }

  bool _compareFaceFeatures(FaceFeatures face1, FaceFeatures face2) {
    const threshold = 10.0;

    if (_comparePoints(face1.rightEye, face2.rightEye, threshold) &&
        _comparePoints(face1.leftEye, face2.leftEye, threshold) &&
        _comparePoints(face1.noseBase, face2.noseBase, threshold) &&
        _comparePoints(face1.rightMouth, face2.rightMouth, threshold) &&
        _comparePoints(face1.leftMouth, face2.leftMouth, threshold)) {
      return true;
    }
    return false;
  }

  bool _comparePoints(Points? p1, Points? p2, double threshold) {
    if (p1 == null || p2 == null) return false;

    final xDiff = (p1.x - p2.x).abs();
    final yDiff = (p1.y - p2.y).abs();

    return xDiff <= threshold && yDiff <= threshold;
  }

  Future<void> _registerUser() async {
    if (!_isFaceDetected) {
      CustomSnackBar.errorSnackBar(
          "Wajah tidak terdeteksi! Silakan ambil ulang foto.");
      return;
    }

    if (!_formFieldKey.currentState!.validate() ||
        !_formFieldKey2.currentState!.validate()) {
      return;
    }

    if (_selectedProgram == null) {
      CustomSnackBar.errorSnackBar("Silakan pilih program studi!");
      return;
    }

    if (_selectedSemester == null) {
      CustomSnackBar.errorSnackBar("Silakan pilih semester!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim().toUpperCase();
      final nim = _nimController.text.trim().toUpperCase();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(color: accentColor),
          ),
        ),
      );

      final userExists = await _checkExistingUser(name, nim, widget.image);

      if (userExists) {
        Navigator.of(context).pop();
        return;
      }

      final userId = const Uuid().v1();
      final user = UserModel(
        id: userId,
        name: name,
        nim: nim,
        image: widget.image,
        program: _selectedProgram!,
        semester: _selectedSemester!,
        registeredOn: DateTime.now().millisecondsSinceEpoch,
        faceFeatures: widget.faceFeatures!,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(user.toJson());

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.successSnackBar("Registrasi berhasil!");

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context)
            ..pop()
            ..pop();
        });
      }
    } catch (e) {
      log("Registration Error: $e");
      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.errorSnackBar("Registrasi gagal! Silakan coba lagi.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 450,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: Color.fromARGB(255, 19, 1, 51),
              ),
              child: Image.asset('assets/ty.png'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 350),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Nama Lengkap dan Nomor Induk Mahasiswa',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Autentikasi Nama dan NIM',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          formFieldKey: _formFieldKey2,
                          controller: _nameController,
                          hintText: "Nama Lengkap",
                          validatorText: "Nama tidak boleh kosong",
                        ),
                        const SizedBox(height: 10),
                        CustomTextField3(
                          formFieldKey: _formFieldKey,
                          controller: _nimController,
                          hintText: "Nomor Induk Mahasiswa",
                          validatorText: "NIM tidak boleh kosong",
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text("Pilih Program Studi"),
                              value: _selectedProgram,
                              items: _programs.map((String program) {
                                return DropdownMenuItem<String>(
                                  value: program,
                                  child: Text(program),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedProgram = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              hint: const Text("Pilih Semester"),
                              value: _selectedSemester,
                              items: _semesters.map((int semester) {
                                return DropdownMenuItem<int>(
                                  value: semester,
                                  child: Text("Semester $semester"),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedSemester = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: _isLoading ? "Processing..." : "Register Now",
                          onTap: _isFaceDetected
                              ? (_isLoading ? null : _registerUser)
                              : null,
                          color: _isFaceDetected ? null : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
