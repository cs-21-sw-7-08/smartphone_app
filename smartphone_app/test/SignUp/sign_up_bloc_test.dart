// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smartphone_app/pages/sign_up/sign_up_bloc.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_events_states.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("SignUp", () {
    late SignUpBloc bloc;

    setUp(() {
      bloc = SignUpBloc(
          context: MockBuildContext(),
          signUpPageView: SignUpPageView.phoneNo,
          email: null,
          name: null);
    });

    test("Initial state is correct", () {
      expect(
          SignUpBloc(
                  context: MockBuildContext(),
                  email: 'test@gmail.com',
                  name: "Test",
                  signUpPageView: SignUpPageView.phoneNo)
              .state,
          SignUpState(signUpPageView: SignUpPageView.phoneNo, name: "Test"));
    });

    blocTest<SignUpBloc, SignUpState>("TextChanged -> name",
        build: () => bloc,
        act: (bloc) => bloc.add(const TextChanged(
            textChangedEvent: SignUpTextChangedEvent.name, text: "Test")),
        expect: () => [bloc.state.copyWith(name: "Test")]);

    blocTest<SignUpBloc, SignUpState>("TextChanged -> phone no.",
        build: () => bloc,
        act: (bloc) => bloc.add(const TextChanged(
            textChangedEvent: SignUpTextChangedEvent.phoneNo,
            text: "12345678")),
        expect: () => [bloc.state.copyWith(phoneNo: "12345678")]);

    blocTest<SignUpBloc, SignUpState>("TextChanged -> sms code",
        build: () => bloc,
        act: (bloc) => bloc.add(const TextChanged(
            textChangedEvent: SignUpTextChangedEvent.smsCode,
            text: "123456")),
        expect: () => [bloc.state.copyWith(smsCode: "123456")]);

    blocTest<SignUpBloc, SignUpState>("MakeViewChange -> name",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const MakeViewChange(pageView: SignUpPageView.name)),
        expect: () =>
            [bloc.state.copyWith(signUpPageView: SignUpPageView.name)]);

    blocTest<SignUpBloc, SignUpState>("MakeViewChange -> name",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const MakeViewChange(pageView: SignUpPageView.name)),
        expect: () =>
        [bloc.state.copyWith(signUpPageView: SignUpPageView.name)]);

    blocTest<SignUpBloc, SignUpState>("VerificationIdRetrieved",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const VerificationIdRetrieved(verificationId: "this is an id")),
        expect: () =>
        [bloc.state.copyWith(verificationId: "this is an id")]);
  });
}
