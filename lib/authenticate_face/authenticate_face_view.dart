import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:absen/authenticate_face/scanning_animation/animated_view.dart';
import 'package:absen/authenticate_face/user_details_view.dart';
import 'package:absen/common/utils/custom_snackbar.dart';
import 'package:absen/common/utils/extensions/size_extension.dart';
import 'package:absen/common/utils/extract_face_feature.dart';
import 'package:absen/common/views/camera_view.dart';
import 'package:absen/common/views/custom_button.dart';
import 'package:absen/constants/theme.dart';
import 'package:absen/model/user_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';

class AuthenticateFaceView extends StatefulWidget {
  const AuthenticateFaceView({Key? key}) : super(key: key);

  @override
  State<AuthenticateFaceView> createState() => _AuthenticateFaceViewState();
}

class _AuthenticateFaceViewState extends State<AuthenticateFaceView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  final TextEditingController _nameController = TextEditingController();
  String _similarity = "";
  bool _canAuthenticate = false;
  List<dynamic> users = [];
  bool userExists = false;
  UserModel? loggingUser;
  bool isMatching = false;
  int trialNumber = 1;

  @override
  void dispose() {
    _faceDetector.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  get _playScanningAudio => _audioPlayer
    ..setReleaseMode(ReleaseMode.loop)
    ..play(AssetSource("hand_scand.wav"));

  get _playFailedAudio => _audioPlayer
    ..stop()
    ..setReleaseMode(ReleaseMode.release)
    ..play(AssetSource("jaya.mp3"));

  Future<void> _logGagalLogin({
    required String nama,
    required int jumlahPercobaan,
    required double? nilaiKemiripan,
    String? idOrganisasi,
  }) async {
    try {
      final sekarang = DateTime.now();
      final formatTanggal = DateFormat('yyyy-MM-dd');
      final formatWaktu = DateFormat('HH:mm:ss');

      await FirebaseFirestore.instance.collection('gagal-login').add({
        'nama': nama,
        'idOrganisasi': idOrganisasi,
        'jumlahPercobaan': jumlahPercobaan,
        'nilaiKemiripan': nilaiKemiripan,
        'tanggal': formatTanggal.format(sekarang),
        'waktu': formatWaktu.format(sekarang),
        'capWaktu': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error pencatatan gagal login: $e');
    }
  }

  String _getCurrentAcademicYear() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if (month >= 9) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }

  Future<void> _logAttendance(UserModel user) async {
    try {
      final now = DateTime.now();
      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
      final DateFormat timeFormatter = DateFormat('HH:mm:ss');

      final String documentId = '${user.nim}_${dateFormatter.format(now)}';

      final existingAttendance = await FirebaseFirestore.instance
          .collection('absen')
          .doc(documentId)
          .get();

      if (existingAttendance.exists) {
        CustomSnackBar.errorSnackBar('Attendance already recorded for today');
        return;
      }

      final attendanceData = {
        'id': user.id,
        'nim': user.nim,
        'nama': user.name,
        'program': user.program,
        'semester': user.semester,
        'date': dateFormatter.format(now),
        'timeIn': timeFormatter.format(now),
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': null,
        'longitude': null,
        'deviceInfo': null,
        'status': 'present',
        'recordType': 'attendance',
        'academicYear': _getCurrentAcademicYear(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('absen')
          .doc(documentId)
          .set(attendanceData);

      CustomSnackBar.successSnackBar('Attendance logged successfully');
    } catch (e) {
      log('Attendance logging error: $e');
      CustomSnackBar.errorSnackBar('Failed to log attendance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constrains) => Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 0.82.sh,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CameraView(
                                onImage: (image) {
                                  _setImage(image);
                                },
                                onInputImage: (inputImage) async {
                                  setState(() => isMatching = true);
                                  _faceFeatures = await extractFaceFeatures(
                                      inputImage, _faceDetector);
                                  setState(() => isMatching = false);
                                },
                              ),
                              if (isMatching)
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0.064.sh),
                                    child: const AnimatedView(),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (_canAuthenticate)
                            CustomButton(
                              text: "Autentikasi",
                              onTap: () {
                                setState(() => isMatching = true);
                                _playScanningAudio;
                                _fetchUsersAndMatchFace();
                              },
                            ),
                          SizedBox(height: 0.038.sh),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _setImage(Uint8List imageToAuthenticate) async {
    image2.bitmap = base64Encode(imageToAuthenticate);
    image2.imageType = regula.ImageType.PRINTED;

    setState(() {
      _canAuthenticate = true;
    });
  }

  double compareFaces(FaceFeatures face1, FaceFeatures face2) {
    double distEar1 = euclideanDistance(face1.rightEar, face1.leftEar);
    double distEar2 = euclideanDistance(face2.rightEar, face2.leftEar);
    double ratioEar = distEar1 / distEar2;

    double distEye1 = euclideanDistance(face1.rightEye, face1.leftEye);
    double distEye2 = euclideanDistance(face2.rightEye, face2.leftEye);
    double ratioEye = distEye1 / distEye2;

    double distCheek1 = euclideanDistance(face1.rightCheek, face1.leftCheek);
    double distCheek2 = euclideanDistance(face2.rightCheek, face2.leftCheek);
    double ratioCheek = distCheek1 / distCheek2;

    double distMouth1 = euclideanDistance(face1.rightMouth, face1.leftMouth);
    double distMouth2 = euclideanDistance(face2.rightMouth, face2.leftMouth);
    double ratioMouth = distMouth1 / distMouth2;

    double distNoseToMouth1 =
        euclideanDistance(face1.noseBase, face1.bottomMouth);
    double distNoseToMouth2 =
        euclideanDistance(face2.noseBase, face2.bottomMouth);
    double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

    double ratio =
        (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
    log(ratio.toString(), name: "Ratio");

    return ratio;
  }

  double euclideanDistance(Points p1, Points p2) {
    return math.sqrt(math.pow((p1.x - p2.x), 2) + math.pow((p1.y - p2.y), 2));
  }

  _fetchUsersAndMatchFace() {
    // ignore: body_might_complete_normally_catch_error
    FirebaseFirestore.instance.collection("users").get().catchError((e) {
      log("Getting User Error: $e");
      setState(() => isMatching = false);
      _playFailedAudio;
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();
        log(snap.docs.length.toString(), name: "Total Registered Users");
        for (var doc in snap.docs) {
          UserModel user = UserModel.fromJson(doc.data());
          double similarity = compareFaces(_faceFeatures!, user.faceFeatures);
          if (similarity >= 0.8 && similarity <= 1.5) {
            users.add([user, similarity]);
          }
        }
        log(users.length.toString(), name: "Filtered Users");
        setState(() {
          users.sort((a, b) => (((a.last as double) - 1).abs())
              .compareTo(((b.last as double) - 1).abs()));
        });

        _matchFaces();
      } else {
        _showFailureDialog(
          title: "No Users Registered",
          description:
              "Make sure users are registered first before Authenticating.",
        );
      }
    });
  }

  _matchFaces() async {
    bool faceMatched = false;
    for (List user in users) {
      image1.bitmap = (user.first as UserModel).image;
      image1.imageType = regula.ImageType.PRINTED;

      var request = regula.MatchFacesRequest();
      request.images = [image1, image2];
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);

      var split =
          regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));
      setState(() {
        _similarity = split!.matchedFaces.isNotEmpty
            ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
            : "error";
        log("similarity: $_similarity");

        if (_similarity != "error" && double.parse(_similarity) > 90.00) {
          faceMatched = true;
          loggingUser = user.first;
        } else {
          faceMatched = false;
        }
      });

      if (faceMatched) {
        _audioPlayer
          ..stop()
          ..setReleaseMode(ReleaseMode.release)
          ..play(AssetSource("wait.wav"));

        await _logAttendance(loggingUser!);

        setState(() {
          trialNumber = 1;
          isMatching = false;
        });

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserDetailsView(user: loggingUser!),
            ),
          );
        }
        break;
      }
    }

    if (!faceMatched) {
      if (trialNumber == 2) {
        setState(() => trialNumber = 1);
        await _logGagalLogin(
          nama: _nameController.text.trim(),
          jumlahPercobaan: trialNumber,
          nilaiKemiripan:
              _similarity != "error" ? double.parse(_similarity) : null,
          idOrganisasi: _nameController.text.trim(),
        );
        _showFailureDialog(
          title: "Proses Gagal",
          description: "Wajah tidak cocok. Silakan coba lagi.",
        );
      } else if (trialNumber == 1) {
        _audioPlayer.stop();
        setState(() {
          isMatching = false;
          trialNumber++;
        });
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Masukkan Nama"),
                content: TextFormField(
                  controller: _nameController,
                  cursorColor: accentColor,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2,
                        color: accentColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2,
                        color: accentColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (_nameController.text.trim().isEmpty) {
                        CustomSnackBar.errorSnackBar(
                            "Masukkan nama untuk melanjutkan");
                      } else {
                        await _logGagalLogin(
                          nama: _nameController.text.trim(),
                          jumlahPercobaan: trialNumber,
                          nilaiKemiripan: _similarity != "error"
                              ? double.parse(_similarity)
                              : null,
                          idOrganisasi: _nameController.text.trim(),
                        );
                        Navigator.of(context).pop();
                        setState(() => isMatching = true);
                        _playScanningAudio;
                        _fetchUserByName(_nameController.text.trim());
                      }
                    },
                    child: const Text(
                      "Selesai",
                      style: TextStyle(
                        color: accentColor,
                      ),
                    ),
                  )
                ],
              );
            });
      } else {
        setState(() => trialNumber++);
        await _logGagalLogin(
          nama: _nameController.text.trim(),
          jumlahPercobaan: trialNumber,
          nilaiKemiripan:
              _similarity != "error" ? double.parse(_similarity) : null,
          idOrganisasi: _nameController.text.trim(),
        );
        _showFailureDialog(
          title: "Proses Gagal",
          description: "Wajah tidak cocok. Silakan coba lagi.",
        );
      }
    }
  }

  _fetchUserByName(String orgID) {
    FirebaseFirestore.instance
        .collection("users")
        .where("organizationId", isEqualTo: orgID)
        .get()
        // ignore: body_might_complete_normally_catch_error
        .catchError((e) {
      log("Getting User Error: $e");
      setState(() => isMatching = false);
      _playFailedAudio;
      CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();

        for (var doc in snap.docs) {
          setState(() {
            users.add([UserModel.fromJson(doc.data()), 1]);
          });
        }
        _matchFaces();
      } else {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          title: "User Not Found",
          description:
              "User is not registered yet. Register first to authenticate.",
        );
      }
    });
  }

  _showFailureDialog({
    required String title,
    required String description,
  }) {
    _playFailedAudio;
    setState(() => isMatching = false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: accentColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
