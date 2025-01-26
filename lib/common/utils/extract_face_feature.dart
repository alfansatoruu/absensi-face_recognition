import 'package:absen/model/user_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

Future<FaceFeatures> extractFaceFeatures(
    InputImage inputImage, FaceDetector faceDetector,
    {int maxRetries = 5, int delayBetweenRetries = 1000}) async {
  List<Face> faceList;
  int attempt = 0;

  // Retry loop
  do {
    faceList = await faceDetector.processImage(inputImage);
    attempt++;
    if (faceList.isEmpty && attempt < maxRetries) {
      await Future.delayed(Duration(milliseconds: delayBetweenRetries));
    }
  } while (faceList.isEmpty && attempt < maxRetries);

  // Check if faceList is still empty after retries
  if (faceList.isEmpty) {
    throw Exception("Wajah tidak terdeteksi");
  }

  Face face = faceList.first;

  FaceFeatures faceFeatures = FaceFeatures(
    rightEar: Points(
        x: (face.landmarks[FaceLandmarkType.rightEar])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.rightEar])?.position.y ?? 0),
    leftEar: Points(
        x: (face.landmarks[FaceLandmarkType.leftEar])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.leftEar])?.position.y ?? 0),
    rightMouth: Points(
        x: (face.landmarks[FaceLandmarkType.rightMouth])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.rightMouth])?.position.y ?? 0),
    leftMouth: Points(
        x: (face.landmarks[FaceLandmarkType.leftMouth])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.leftMouth])?.position.y ?? 0),
    rightEye: Points(
        x: (face.landmarks[FaceLandmarkType.rightEye])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.rightEye])?.position.y ?? 0),
    leftEye: Points(
        x: (face.landmarks[FaceLandmarkType.leftEye])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.leftEye])?.position.y ?? 0),
    rightCheek: Points(
        x: (face.landmarks[FaceLandmarkType.rightCheek])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.rightCheek])?.position.y ?? 0),
    leftCheek: Points(
        x: (face.landmarks[FaceLandmarkType.leftCheek])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.leftCheek])?.position.y ?? 0),
    noseBase: Points(
        x: (face.landmarks[FaceLandmarkType.noseBase])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.noseBase])?.position.y ?? 0),
    bottomMouth: Points(
        x: (face.landmarks[FaceLandmarkType.bottomMouth])?.position.x ?? 0,
        y: (face.landmarks[FaceLandmarkType.bottomMouth])?.position.y ?? 0),
  );

  return faceFeatures;
}
