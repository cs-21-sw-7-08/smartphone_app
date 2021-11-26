import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_text_field.dart';
import 'package:smartphone_app/values/values.dart' as values;

import 'sign_up_bloc.dart';
import 'sign_up_events_states.dart';

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  late SignUpBloc bloc;
  late SignUpPageView signUpPageView;
  late String? name;
  late String? email;

  SignUpPage(
      {Key? key,
      this.name,
      this.email})
      : super(key: key) {
    signUpPageView =
        name == null ? SignUpPageView.phoneNo : SignUpPageView.name;
  }

  @override
  Widget build(BuildContext context) {
    bloc = SignUpBloc(
        email: email,
        buildContext: context,
        signUpPageView: signUpPageView,
        name: name);

    return WillPopScope(
        onWillPop: () async {
          bloc.add(ButtonPressed(signUpButtonEvent: SignUpButtonEvent.back));
          return false;
        },
        child: FutureBuilder<bool>(
            future: bloc.getValues(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(color: Colors.white);
              }
              return BlocProvider(
                  create: (_) => bloc,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(
                          child: Container(
                              constraints: const BoxConstraints.expand(),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: ExactAssetImage(
                                      values.createIssueBackground,
                                    )),
                              ),
                              child: BlocBuilder<SignUpBloc, SignUpState>(
                                  builder: (context, state) {
                                return Scaffold(
                                    backgroundColor: Colors.transparent,
                                    appBar: CustomAppBar(
                                      title:
                                          AppLocalizations.of(context)!.sign_up,
                                      titleColor: Colors.white,
                                      background:
                                          custom_colors.appBarBackground,
                                      appBarLeftButton: AppBarLeftButton.back,
                                      leftButtonPressed: () => bloc.add(
                                          ButtonPressed(
                                              signUpButtonEvent:
                                                  SignUpButtonEvent.back)),
                                    ),
                                    body: getContent(context, bloc, state));
                              })))));
            }));
  }

  Widget getContent(BuildContext context, SignUpBloc bloc, SignUpState state) {
    List<Widget>? children;
    switch (state.signUpPageView!) {
      case SignUpPageView.phoneNo:
        children = [
          _getMessage(
              AppLocalizations.of(context)!.please_enter_your_phone_number),
          Card(
              margin: const EdgeInsets.only(
                  top: values.padding,
                  left: values.padding,
                  right: values.padding),
              child: Column(
                children: [
                  _getHeader(AppLocalizations.of(context)!.phone_number),
                  _getPhoneNumber(context, bloc, state)
                ],
              ))
        ];
        break;
      case SignUpPageView.name:
        children = [
          _getMessage(
              AppLocalizations.of(context)!.please_enter_your_full_name),
          Card(
              margin: const EdgeInsets.only(
                  top: values.padding,
                  left: values.padding,
                  right: values.padding),
              child: Column(
                children: [
                  _getHeader(AppLocalizations.of(context)!.name),
                  _getName(context, bloc, state)
                ],
              )),
          Card(
              margin: const EdgeInsets.only(
                  top: values.padding,
                  left: values.padding,
                  right: values.padding),
              child: Column(
                children: [
                  _getHeader(AppLocalizations.of(context)!.municipality),
                  _getMunicipality(context, bloc, state)
                ],
              ))
        ];
        break;
      case SignUpPageView.smsCode:
        children = [
          _getMessage(AppLocalizations.of(context)!.please_enter_the_sms_code),
          Card(
              margin: const EdgeInsets.only(
                  top: values.padding,
                  left: values.padding,
                  right: values.padding),
              child: Column(
                children: [
                  _getHeader(AppLocalizations.of(context)!.sms_code),
                  _getSmsCode(context, bloc, state)
                ],
              )),
        ];
        break;
    }

    return ClipRect(
        child: Container(
            constraints: const BoxConstraints.expand(),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  children: children,
                                ))),
                        // 'Confirm' button
                        CustomButton(
                          onPressed: () {
                            switch (state.signUpPageView!) {
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
                          text: AppLocalizations.of(context)!.confirm,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          margin: const EdgeInsets.all(values.padding),
                        )
                      ],
                    )))));
  }

  Widget _getHeader(String title) {
    return Column(
      children: [
        CustomLabel(
          title: title,
          fontWeight: FontWeight.bold,
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.only(
              left: values.padding,
              right: values.padding,
              top: values.padding,
              bottom: values.smallPadding),
        ),
        Container(
          height: 1,
          color: custom_colors.contentDivider,
          margin: const EdgeInsets.only(
              left: values.padding, right: values.padding),
        ),
      ],
    );
  }

  Widget _getMessage(String message) {
    return Card(
        color: Colors.white,
        margin: const EdgeInsets.only(
            top: values.padding, left: values.padding, right: values.padding),
        child: Column(
          children: [
            CustomLabel(
              title: message,
              textAlign: TextAlign.center,
              alignmentGeometry: Alignment.center,
              margin: const EdgeInsets.only(
                  left: values.padding,
                  top: values.padding * 2,
                  right: values.padding,
                  bottom: values.padding * 2),
            )
          ],
        ));
  }

  Widget _getPhoneNumber(
      BuildContext context, SignUpBloc bloc, SignUpState state) {
    return Container(
      margin: const EdgeInsets.only(
          left: values.padding,
          right: values.padding,
          top: values.padding,
          bottom: values.padding),
      child: CustomTextField(
        maxLength: 8,
        keyBoardType: TextInputType.number,
        text: state.phoneNo,
        onChanged: (text) {
          bloc.add(TextChanged(
              signUpTextChangedEvent: SignUpTextChangedEvent.phoneNo,
              text: text));
        },
        margin: const EdgeInsets.all(0),
      ),
    );
  }

  Widget _getSmsCode(BuildContext context, SignUpBloc bloc, SignUpState state) {
    return Container(
      margin: const EdgeInsets.only(
          left: values.padding,
          right: values.padding,
          top: values.padding,
          bottom: values.padding),
      child: CustomTextField(
        maxLength: 6,
        keyBoardType: TextInputType.number,
        text: state.smsCode,
        onChanged: (text) {
          bloc.add(TextChanged(
              signUpTextChangedEvent: SignUpTextChangedEvent.smsCode,
              text: text));
        },
        margin: const EdgeInsets.all(0),
      ),
    );
  }

  Widget _getMunicipality(
      BuildContext context, SignUpBloc bloc, SignUpState state) {
    return Container(
        margin: const EdgeInsets.only(
            left: values.padding,
            top: values.padding,
            right: values.padding,
            bottom: values.padding),
        child: Column(
          children: [
            if (state.municipality != null)
              Column(
                children: [
                  CustomLabel(
                    title: state.municipality!.name!,
                    margin: const EdgeInsets.all(0),
                  ),
                ],
              ),
            CustomButton(
              onPressed: () => bloc.add(ButtonPressed(
                  signUpButtonEvent: SignUpButtonEvent.selectMunicipality)),
              margin: EdgeInsets.only(
                  top: (state.municipality != null) ? values.padding : 0),
              fontWeight: FontWeight.bold,
              text: state.municipality == null
                  ? AppLocalizations.of(context)!.select_municipality
                  : AppLocalizations.of(context)!.change_municipality,
            )
          ],
        ));
  }

  Widget _getName(BuildContext context, SignUpBloc bloc, SignUpState state) {
    return Container(
      margin: const EdgeInsets.only(
          left: values.padding,
          right: values.padding,
          top: values.padding,
          bottom: values.padding),
      child: CustomTextField(
        keyBoardType: TextInputType.text,
        initialValue: state.name,
        text: state.name,
        onChanged: (text) {
          bloc.add(TextChanged(
              signUpTextChangedEvent: SignUpTextChangedEvent.name, text: text));
        },
        margin: const EdgeInsets.all(0),
      ),
    );
  }
}
