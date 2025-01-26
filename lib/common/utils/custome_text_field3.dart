import 'package:absen/common/utils/extensions/size_extension.dart';
import 'package:absen/constants/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField3 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final GlobalKey formFieldKey;
  final String validatorText;

  const CustomTextField3({
    super.key,
    required this.formFieldKey,
    required this.controller,
    required this.hintText,
    required this.validatorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.055.sw, vertical: 0.02.sh),
      child: TextFormField(
        keyboardType: TextInputType.number,
        key: formFieldKey,
        controller: controller,
        cursorColor: primaryBlack.withOpacity(0.8),
        style: const TextStyle(
          color: primaryBlack,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: primaryBlack),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return validatorText;
          } else {
            return null;
          }
        },
      ),
    );
  }
}
