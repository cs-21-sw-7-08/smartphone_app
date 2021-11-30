import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import 'helpers/app_values_helper.dart';
import 'localization/localization_helper.dart';
import 'package:smartphone_app/values/values.dart' as values;

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await AppValuesHelper.getInstance().init();
  await Firebase.initializeApp();
  WASPService.init(WASPService(url: "https://192.168.0.167:5001"));
  //WASPService.init(MockWASPService());
  GoogleService.init(GoogleService());

  // Pre-cache SVG
  await Future.wait([
    precachePicture(
      ExactAssetPicture(
          SvgPicture.svgStringDecoderBuilder, values.appFeatureImage),
      null,
    ),
    // other SVGs or images here
  ]);

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
    User? user = ThirdPartySignInUtil.getUser();
    int? citizenId =
        AppValuesHelper.getInstance().getInteger(AppValuesKey.citizenId);

    return MaterialApp(
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
                ? const IssuesOverviewPage()
                : SignUpPage(
                    name: user!.displayName ?? "",
                    email: user.email,
                  ))
            : const LoginPage());
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
