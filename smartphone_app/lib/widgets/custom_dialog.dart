import 'package:flutter/material.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class CustomDialog extends Dialog {
  ///
  /// VARIABLES
  ///
  //region Variables

  Function(CustomDialog)? onCancelPressed;
  BuildContext context;
  String progressMessage;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  CustomDialog(
      {Key? key,
      required this.context,
      required this.progressMessage,
      this.onCancelPressed})
      : super(key: key);

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  /// Dismiss the dialog
  dismiss() {
    Navigator.pop(context, null);
  }

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
                  borderRadius: BorderRadius.all(Radius.circular(2))),
              child: Wrap(alignment: WrapAlignment.center, children: [
                Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Container(
                      height: 50,
                      width: 50,
                      child: const CircularProgressIndicator(
                        color: custom_colors.blue,
                      )),
                ),
                Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 25, top: 25),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        progressMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    )),
                CustomButton(
                    text: AppLocalizations.of(context)!.cancel,
                    defaultBackground: custom_colors.buttonGradientDefault2,
                    textColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(2)),
                    showBorder: false,
                    onPressed: () => {
                          if (onCancelPressed != null) {onCancelPressed!(this)}
                        })
              ])),
        ));
  }

//endregion

}
