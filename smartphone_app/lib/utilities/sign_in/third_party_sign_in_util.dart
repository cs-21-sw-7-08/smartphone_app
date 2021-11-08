import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInResponse {
  GoogleSignInAccount googleSignInAccount;
  User user;

  SignInResponse(this.user, this.googleSignInAccount);
}

class ThirdPartySignInUtil {
  static GoogleSignIn _getGoogleSignIn() {
    return GoogleSignIn(
      scopes: [
        'email',
      ],
    );
  }

  static Future<SignInResponse?> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount =
        await _getGoogleSignIn().signIn();
    if (googleSignInAccount == null) return null;
    var googleSignInAuthentication = await googleSignInAccount.authentication;
    var credentials = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    UserCredential? userCredential =
        await signInWithCredentials(credentials);
    if (userCredential == null) return null;
    return SignInResponse(userCredential.user!, googleSignInAccount);
  }

  static Future<void> verifyPhoneNo(
      {required String phoneNumber,
        required PhoneVerificationCompleted verificationCompleted,
        required PhoneVerificationFailed verificationFailed,
        required PhoneCodeSent codeSent,
        required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  static Future<UserCredential> signInWithSmsCode(
      String verificationId, String verificationCode) {
    return FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: verificationCode));
  }

  static Future<UserCredential> signInWithCredentials(
      AuthCredential authCredential) {
    return FirebaseAuth.instance.signInWithCredential(authCredential);
  }

  static Future<void> signOut() async {
    try {
      await _getGoogleSignIn().disconnect();
    } on Exception catch (_) {

    }
    return FirebaseAuth.instance.signOut();
  }

  static bool isSignedIn() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  static User? getUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
