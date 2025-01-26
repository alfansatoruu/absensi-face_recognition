class UserModel {
  final String id;
  final String name;
  final String nim;
  final String image;
  final String program;
  final int semester;
  final FaceFeatures faceFeatures;
  final int registeredOn;

  const UserModel({
    required this.id,
    required this.name,
    required this.nim,
    required this.image,
    required this.program,
    required this.semester,
    required this.faceFeatures,
    required this.registeredOn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nim: json['nim'] as String? ?? '',
      image: json['image'] as String? ?? '',
      program: json['program'] as String? ?? '',
      semester: json['semester'] as int? ?? 1,
      faceFeatures: FaceFeatures.fromJson(
          json['faceFeatures'] as Map<String, dynamic>? ?? {}),
      registeredOn:
          json['registeredOn'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nim': nim,
      'image': image,
      'program': program,
      'semester': semester,
      'faceFeatures': faceFeatures.toJson(),
      'registeredOn': registeredOn,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? nim,
    String? image,
    String? program,
    int? semester,
    FaceFeatures? faceFeatures,
    int? registeredOn,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      image: image ?? this.image,
      program: program ?? this.program,
      semester: semester ?? this.semester,
      faceFeatures: faceFeatures ?? this.faceFeatures,
      registeredOn: registeredOn ?? this.registeredOn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          nim == other.nim &&
          image == other.image &&
          program == other.program &&
          semester == other.semester &&
          faceFeatures == other.faceFeatures &&
          registeredOn == other.registeredOn;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      nim.hashCode ^
      image.hashCode ^
      program.hashCode ^
      semester.hashCode ^
      faceFeatures.hashCode ^
      registeredOn.hashCode;
}

class FaceFeatures {
  final Points rightEar;
  final Points leftEar;
  final Points rightEye;
  final Points leftEye;
  final Points rightCheek;
  final Points leftCheek;
  final Points rightMouth;
  final Points leftMouth;
  final Points noseBase;
  final Points bottomMouth;

  const FaceFeatures({
    required this.rightMouth,
    required this.leftMouth,
    required this.leftCheek,
    required this.rightCheek,
    required this.leftEye,
    required this.rightEar,
    required this.leftEar,
    required this.rightEye,
    required this.noseBase,
    required this.bottomMouth,
  });

  factory FaceFeatures.fromJson(Map<String, dynamic> json) => FaceFeatures(
        rightMouth:
            Points.fromJson(json['rightMouth'] as Map<String, dynamic>?),
        leftMouth: Points.fromJson(json['leftMouth'] as Map<String, dynamic>?),
        leftCheek: Points.fromJson(json['leftCheek'] as Map<String, dynamic>?),
        rightCheek:
            Points.fromJson(json['rightCheek'] as Map<String, dynamic>?),
        leftEye: Points.fromJson(json['leftEye'] as Map<String, dynamic>?),
        rightEar: Points.fromJson(json['rightEar'] as Map<String, dynamic>?),
        leftEar: Points.fromJson(json['leftEar'] as Map<String, dynamic>?),
        rightEye: Points.fromJson(json['rightEye'] as Map<String, dynamic>?),
        noseBase: Points.fromJson(json['noseBase'] as Map<String, dynamic>?),
        bottomMouth:
            Points.fromJson(json['bottomMouth'] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toJson() => {
        'rightMouth': rightMouth.toJson(),
        'leftMouth': leftMouth.toJson(),
        'leftCheek': leftCheek.toJson(),
        'rightCheek': rightCheek.toJson(),
        'leftEye': leftEye.toJson(),
        'rightEar': rightEar.toJson(),
        'leftEar': leftEar.toJson(),
        'rightEye': rightEye.toJson(),
        'noseBase': noseBase.toJson(),
        'bottomMouth': bottomMouth.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaceFeatures &&
          runtimeType == other.runtimeType &&
          rightEar == other.rightEar &&
          leftEar == other.leftEar &&
          rightEye == other.rightEye &&
          leftEye == other.leftEye &&
          rightCheek == other.rightCheek &&
          leftCheek == other.leftCheek &&
          rightMouth == other.rightMouth &&
          leftMouth == other.leftMouth &&
          noseBase == other.noseBase &&
          bottomMouth == other.bottomMouth;

  @override
  int get hashCode =>
      rightEar.hashCode ^
      leftEar.hashCode ^
      rightEye.hashCode ^
      leftEye.hashCode ^
      rightCheek.hashCode ^
      leftCheek.hashCode ^
      rightMouth.hashCode ^
      leftMouth.hashCode ^
      noseBase.hashCode ^
      bottomMouth.hashCode;
}

class Points {
  final int x;
  final int y;

  const Points({
    required this.x,
    required this.y,
  });

  factory Points.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Points(x: 0, y: 0);
    return Points(
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Points &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
