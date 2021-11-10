import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_page.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/service/google_service.dart';
import 'package:smartphone_app/webservices/wasp/service/mock_wasp_service.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import 'helpers/app_values_helper.dart';
import 'localization/localization_helper.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await AppValuesHelper.getInstance().init();
  await Firebase.initializeApp();
  WASPService.init(MockWASPService());
  GoogleService.init(GoogleService());

  // Pre-cache SVG
  await Future.wait([
    precachePicture(
      ExactAssetPicture(SvgPicture.svgStringDecoderBuilder,
          'assets/beahelper_feature_image.drawio.svg'),
      null,
    ),
    // other SVGs or images here
  ]);

  /*try {
    ThirdPartySignInUtil.signOut();
  } on Exception catch (_) {}*/

  runApp(const MyApp());
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class MyApp extends StatelessWidget {

  // ignore: use_key_in_widget_constructors
  const MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    LocalizationHelper.init(context: context);

    var localizations = [AppLocalizations.localizationsDelegates]
        .expand((element) => element)
        .toList();

    bool isSignedIn = ThirdPartySignInUtil.isSignedIn();
    int? citizenId =
        AppValuesHelper.getInstance().getInteger(AppValuesKey.citizenId);

    return MaterialApp(
      navigatorObservers: [MyNavigatorObserver()],
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          );
        },
        localizationsDelegates: localizations,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: isSignedIn
            ? (citizenId != null
                ? IssuesOverviewPage()
                : SignUpPage(
                    name: "",
                  ))
            : LoginPage());
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  List<Route<dynamic>> routeStack = List.empty(growable: true);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.add(route);
    print("Push");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    print("Pop");
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    routeStack.removeLast();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    routeStack.removeLast();
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
  }
}
