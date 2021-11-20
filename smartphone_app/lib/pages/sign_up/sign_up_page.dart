import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_text_field.dart';

import 'sign_up_bloc.dart';
import 'sign_up_events_states.dart';

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  late SignUpBloc bloc;
  SignUpPageView signUpPageView;
  late String? name;

  SignUpPage(
      {Key? key, this.name, this.signUpPageView = SignUpPageView.phoneNo})
      : super(key: key) {
    signUpPageView =
        name == null ? SignUpPageView.phoneNo : SignUpPageView.name;
  }

  @override
  Widget build(BuildContext context) {
    SignUpBloc bloc = SignUpBloc(
        buildContext: context, signUpPageView: signUpPageView, name: name);

    return WillPopScope(
        onWillPop: () async {
          await GeneralUtil.goToPage(context, LoginPage(), goBack: true);
          return false;
        },
        child: BlocProvider(
            create: (_) => bloc,
            child: Container(
                color: custom_colors.appSafeAreaColor,
                child: SafeArea(
                    child: Scaffold(
                        appBar: CustomAppBar(
                          title: AppLocalizations.of(context)!.sign_up,
                          titleColor: Colors.white,
                          background: custom_colors.appBarBackground,
                          appBarLeftButton: AppBarLeftButton.back,
                          leftButtonPressed: () async => {
                            await GeneralUtil.goToPage(context, LoginPage(),
                                goBack: true)
                          },
                          button1Icon:
                              const Icon(Icons.check, color: Colors.white),
                          onButton1Pressed: () {
                            switch (bloc.state.signUpPageView!) {
                              case SignUpPageView.phoneNo:
                                bloc.add(ButtonPressed(
                                    signUpButtonEvent:
                                        SignUpButtonEvent.verifyPhoneNo));
                                break;
                              case SignUpPageView.name:
                                bloc.add(ButtonPressed(
                                    signUpButtonEvent:
                                        SignUpButtonEvent.confirmName));
                                break;
                              case SignUpPageView.smsCode:
                                bloc.add(ButtonPressed(
                                    signUpButtonEvent:
                                        SignUpButtonEvent.verifySmsCode));
                                break;
                            }
                          },
                        ),
                        body: getContent(context, bloc))))));
  }

  Widget getContent(BuildContext context, SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
      switch (state.signUpPageView!) {
        case SignUpPageView.phoneNo:
          return Container(
            child: Column(
              children: [
                CustomLabel(title: AppLocalizations.of(context)!.phone_number),
                BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
                  return CustomTextField(
                    maxLength: 8,
                    keyBoardType: TextInputType.number,
                    text: state.phoneNo,
                    onChanged: (text) {
                      bloc.add(TextChanged(
                          signUpTextChangedEvent:
                              SignUpTextChangedEvent.phoneNo,
                          text: text));
                    },
                    margin: const EdgeInsets.only(left: 10, top: 2, right: 10),
                  );
                })
              ],
            ),
          );
        case SignUpPageView.name:
          return Container(
            child: Column(
              children: [
                CustomLabel(title: AppLocalizations.of(context)!.name),
                BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
                  return CustomTextField(
                    keyBoardType: TextInputType.text,
                    initialValue: state.name,
                    text: state.name,
                    onChanged: (text) {
                      bloc.add(TextChanged(
                          signUpTextChangedEvent: SignUpTextChangedEvent.name,
                          text: text));
                    },
                    margin: const EdgeInsets.only(left: 10, top: 2, right: 10),
                  );
                })
              ],
            ),
          );
        case SignUpPageView.smsCode:
          return Container(
            child: Column(
              children: [
                CustomLabel(title: AppLocalizations.of(context)!.sms_code),
                BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
                  return CustomTextField(
                    maxLength: 6,
                    keyBoardType: TextInputType.number,
                    text: state.smsCode,
                    onChanged: (text) {
                      bloc.add(TextChanged(
                          signUpTextChangedEvent:
                              SignUpTextChangedEvent.smsCode,
                          text: text));
                    },
                    margin: const EdgeInsets.only(left: 10, top: 2, right: 10),
                  );
                })
              ],
            ),
          );
      }
    });
  }
}
