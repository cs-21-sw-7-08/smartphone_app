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
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';

import 'package:smartphone_app/pages/login/login_bloc.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockGrantedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.granted;
  }
}

class MockDeniedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

void main() {
  group("Login", () {
    test("Initial state is correct", () {
      expect(
          LoginBloc(
                  context: MockBuildContext(),
                  permissionHelper: MockGrantedPermissionHelper())
              .state,
          LoginState(permissionState: PermissionState.denied));
    });

    blocTest<LoginBloc, LoginState>("Resumed -> Permissions Denied",
        build: () => LoginBloc(
            context: MockBuildContext(),
            permissionHelper: MockDeniedPermissionHelper()),
        act: (bloc) => bloc.add(Resumed()),
        expect: () => [LoginState(permissionState: PermissionState.denied)]);

    blocTest<LoginBloc, LoginState>("Resumed -> Permissions granted",
        build: () => LoginBloc(
            context: MockBuildContext(),
            permissionHelper: MockGrantedPermissionHelper()),
        act: (bloc) => bloc.add(Resumed()),
        expect: () => [LoginState(permissionState: PermissionState.granted)]);

    blocTest<LoginBloc, LoginState>("Permission state changed",
        build: () => LoginBloc(
            context: MockBuildContext(),
            permissionHelper: MockGrantedPermissionHelper()),
        act: (bloc) => bloc.add(const PermissionStateChanged(
            permissionState: PermissionState.granted)),
        expect: () => [LoginState(permissionState: PermissionState.granted)]);
  });
}
