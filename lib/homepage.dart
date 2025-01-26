import 'package:absen/authenticate_face/authenticate_face_view.dart';
import 'package:absen/common/utils/custom_snackbar.dart';
import 'package:absen/common/utils/screen_size_util.dart';
import 'package:absen/common/views/custom_button.dart';
import 'package:absen/register_face/data_admin/user_firestore_service.dart';
import 'package:absen/register_face/register_face_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeUtilContexts(context);
    return Scaffold(
      body: Column(
        children: [
          PhysicalModel(
            color: const Color.fromARGB(0, 33, 201, 224),
            child: Container(
              height: 450,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(20),
                    bottomStart: Radius.circular(20)),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/background.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const GradientAnimationText(
            text: Text(
              'System Absensi Mahasiswa',
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'fontku',
                  fontWeight: FontWeight.bold),
            ),
            colors: [
              Color.fromARGB(255, 6, 123, 155),
              Color.fromARGB(255, 9, 236, 236),
            ],
            duration: Duration(seconds: 5),
          ),
          const SizedBox(
            height: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomButton(
                text: "Buat Akun",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterFaceView(),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                text: "Absen",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthenticateFaceView(),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Colors.grey,
                height: 2,
                thickness: 3,
                indent: 30,
                endIndent: 30,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                text: "Admin",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AbsenPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void initializeUtilContexts(BuildContext context) {
    ScreenSizeUtil.context = context;
    CustomSnackBar.context = context;
  }
}
