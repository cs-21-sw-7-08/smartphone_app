// ignore: must_be_immutable
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';
import 'package:smartphone_app/pages/login/login_bloc.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

// ignore: must_be_immutable, use_key_in_widget_constructors
class _LoginState extends State<LoginPage> with WidgetsBindingObserver {
  LoginBloc? bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: missing_enum_constant_in_switch
    switch (state) {
      case AppLifecycleState.resumed:
        if (bloc != null) {
          bloc!.add(Resumed());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bloc = LoginBloc(context: context, permissionHelper: PermissionHelper());

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: FutureBuilder<PermissionState>(
            future: bloc!.getPermissions(),
            builder: (context, snapshot) {
              /// Main content shown on the login page
              return BlocProvider(
                  create: (_) => bloc!,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(child:
                          Scaffold(body: BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return _getBody(context, bloc!, state, snapshot);
                        },
                      )))));
            }));
  }

  Widget _getBody(BuildContext context, LoginBloc bloc, LoginState state,
      AsyncSnapshot<PermissionState> snapshot) {
    /// Content shown while asking then user for OS permissions like
    /// accessing camera, location etc.
    if (snapshot.connectionState != ConnectionState.done) {
      return Container(
        color: Colors.white,
      );
    }

    /// The user denied one of the permissions
    if (state.permissionState == PermissionState.denied &&
        snapshot.data! == PermissionState.denied) {
      return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomLabel(
              title: AppLocalizations.of(context)!
                  .please_go_to_settings_and_give_bee_a_helper_all_the_necessary_permissions,
            ),
            CustomButton(
              onPressed: () => bloc.add(const ButtonPressed(
                  buttonEvent: LoginButtonEvent.goToSettings)),
              text: AppLocalizations.of(context)!.go_to_settings,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              margin: const EdgeInsets.only(
                  left: values.padding,
                  right: values.padding,
                  top: values.padding),
            )
          ],
        ),
      );
    }

    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: ExactAssetImage(
                  values.loginBackground,
                ))),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
              color: Colors.white.withOpacity(0.5),
              child: _getContent(context, bloc)),
        ));
  }

  Widget _getContent(BuildContext context, LoginBloc bloc) {
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
          onPressed: () => bloc.add(const ButtonPressed(
              buttonEvent: LoginButtonEvent.useGoogleLogin)),
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
              const ButtonPressed(buttonEvent: LoginButtonEvent.useAppleLogin)),
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        ),
        CustomButton(
          text: AppLocalizations.of(context)!.sign_in_with_phone_no,
          fontWeight: FontWeight.bold,
          onPressed: () => bloc.add(
              const ButtonPressed(buttonEvent: LoginButtonEvent.usePhoneNo)),
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
          icon: const Icon(Icons.phone, color: custom_colors.black),
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        ),
      ],
    );
  }
}
