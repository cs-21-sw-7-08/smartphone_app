import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImagePickerDialog extends StatelessWidget {
  ///
  /// STATICS
  ///
  //region Statics

  static Future<Image?> show({required BuildContext context}) async {
    return await Future.delayed(Duration.zero, () async {
      // Show dialog
      return await showDialog(
          context: context,
          builder: (context) => ImagePickerDialog(),
          barrierDismissible: false);
    });
  }

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  final ImagePicker _imagePicker = ImagePicker();

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  // ignore: prefer_const_constructors_in_immutables
  ImagePickerDialog({Key? key}) : super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(values.borderRadius))),
              child: Wrap(alignment: WrapAlignment.center, children: [
                Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.only(
                        left: values.padding,
                        right: values.padding,
                        bottom: 25,
                        top: 25),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!
                            .please_select_how_to_add_the_picture,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    )),
                Container(
                  height: 1,
                  color: Colors.black,
                ),
                CustomButton(
                    text: AppLocalizations.of(context)!.from_gallery,
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.black,
                    ),
                    textColor: Colors.black,
                    fontWeight: FontWeight.bold,
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                    showBorder: false,
                    onPressed: () async {
                      Image? image = await _pickImage(ImageSource.gallery);
                      if (image == null) return;
                      Navigator.of(context).pop(image);
                    }),
                Container(
                  height: 1,
                  color: Colors.black,
                ),
                CustomButton(
                    text: AppLocalizations.of(context)!.take_picture,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                    ),
                    textColor: Colors.black,
                    fontWeight: FontWeight.bold,
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                    showBorder: false,
                    onPressed: () async {
                      Image? image = await _pickImage(ImageSource.camera);
                      if (image == null) return;
                      Navigator.of(context).pop(image);
                    }),
                CustomButton(
                    text: AppLocalizations.of(context)!.cancel,
                    defaultBackground: custom_colors.blackGradient,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(values.borderRadius),
                        bottomRight: Radius.circular(values.borderRadius)),
                    showBorder: false,
                    onPressed: () => Navigator.of(context).pop(null))
              ])),
        ));
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<Image?> _pickImage(ImageSource source) async {
    try {
      final XFile? imageXFile = await _imagePicker.pickImage(source: source);
      if (imageXFile == null) return null;
      File imageFile = File(imageXFile.path);
      return Image.file(imageFile);
    } on Exception catch (_) {
      return null;
    }
  }

//endregion
}
