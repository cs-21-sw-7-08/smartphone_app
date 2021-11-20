// ignore: must_be_immutable
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartphone_app/pages/login/login_bloc.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable, use_key_in_widget_constructors
class LoginPage extends StatelessWidget {
  late LoginBloc bloc;

  @override
  Widget build(BuildContext context) {
    LoginBloc bloc = LoginBloc(buildContext: context);

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: FutureBuilder<PermissionState>(
            future: bloc.getPermissions(),
            builder: (context, snapshot) {
              /// Content shown while asking then user for OS permissions like
              /// accessing camera, location etc.
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  color: Colors.white,
                );
              }

              /// The user denied one of the permissions
              if (snapshot.data! == PermissionState.denied) {
                // TODO: Add design that lets the user go to settings in order
                // TODO: to give permissions
                return Container(color: Colors.red);
              }

              /// Main content shown on the login page
              return BlocProvider(
                  create: (_) => bloc,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(
                          child: Scaffold(
                              body: Container(
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: ExactAssetImage(
                                            values.loginBackground,
                                          ))),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                        color: Colors.white.withOpacity(0.5),
                                        child: getContent(context, bloc)),
                                  ))))));
            }));
  }

  Widget getContent(BuildContext context, LoginBloc bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.only(top: 0, left: 10, right: 10),
            child: SvgPicture.asset(
              values.appFeatureImage,
              fit: BoxFit.contain,
              height: 150,
            )),
        CustomLabel(
          title: AppLocalizations.of(context)!.app_name,
          fontSize: 25,
          margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
          alignmentGeometry: Alignment.center,
          fontWeight: FontWeight.bold,
        ),
        CustomButton(
          text: AppLocalizations.of(context)!.sign_in_with_google,
          fontWeight: FontWeight.bold,
          image: const AssetImage("assets/google_logo.png"),
          imagePadding: const EdgeInsets.all(15),
          onPressed: () => bloc.add(
              ButtonPressed(loginButtonEvent: LoginButtonEvent.useGoogleLogin)),
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
          margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
        ),
        CustomButton(
          text: AppLocalizations.of(context)!.sign_in_with_apple,
          fontWeight: FontWeight.bold,
          image: const AssetImage("assets/apple_logo.png"),
          imagePadding: const EdgeInsets.all(15),
          onPressed: () => bloc.add(
              ButtonPressed(loginButtonEvent: LoginButtonEvent.useAppleLogin)),
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        ),
        CustomButton(
          text: AppLocalizations.of(context)!.sign_in_with_phone_no,
          fontWeight: FontWeight.bold,
          onPressed: () => bloc.add(
              ButtonPressed(loginButtonEvent: LoginButtonEvent.usePhoneNo)),
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
          icon: const Icon(Icons.phone, color: custom_colors.black),
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        ),
      ],
    );
  }
}
