// @dart=2.9
import 'dart:convert';
import 'dart:math';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/views/opt_view.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  final charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class LoginProvider with ChangeNotifier {
  FirebaseAuth _auth;
  SharedPreferences _prefs;
  Map<String, dynamic> _currentUser;

  bool _loggedIn = false;
  bool _loading = false;
  bool _loadingCurrentUser = true;

  // Public access to current user data
  Map<String, dynamic> get currentUser => _currentUser;

  LoginProvider() {
    // Initialize App Provider
    initAppProvider();

    // Check for login state
    checkLoginState();
  }

  void initAppProvider() async {
    _prefs = await SharedPreferences.getInstance();
    _auth = FirebaseAuth.instance;
  }

  bool isLoggedIn() => _loggedIn;

  bool isLoading() => _loading;

  bool isLoadingCurrentUser() => _loadingCurrentUser;

  bool isCompleted() =>
      _currentUser != null ? _currentUser['completed'] == true : false;

  // Main login function
  Future<dynamic> login(String type) async {
    print("============LOGIN"+type);
    _loading = true;
    notifyListeners();

    final AuthResult result = type == 'google'
        ? await signInWithGoogle()
        : (type == 'apple'
            ? await signInWithApple()
            : await signInWithFacebook());

    if (result.status == AuthResult.ok) {
      try {
        UserCredential userCredential =
            await _auth.signInWithCredential(result.credential);
        return afterSignIn(userCredential);
      } on FirebaseAuthException catch (e) {
        print(e);
      }
    } else if (result.status == AuthResult.cancelled) {
      Fluttertoast.showToast(msg: "Haz cancelado el inicio de sesión");
    } else {
      Fluttertoast.showToast(msg: "Ocurrió un error, inténtalo más tarde");
    }

    _loading = false;
    notifyListeners();

    return Future.error("not loggedin");
  }

  // TODO: Testing alternative
  void loginFacebook() async {
    _loading = true;
    notifyListeners();

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
        url: "fisioterapia-cfb53.web.app", callbackUrlScheme: "physiho");

    // Extract status from resulting url
    final params = Uri.parse(result).queryParameters;
    final status = int.parse(params['status']);

    // Success
    if (status == AuthResult.ok) {
      final uid = params['uid'];
      // Save UID on device
      _prefs.setString('uid', uid);
      await checkLoginState();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> afterSignIn(UserCredential userCredential) async {
    _loadingCurrentUser = true;
    notifyListeners();
    // Register in firestore if is a new user
    if (userCredential.additionalUserInfo.isNewUser) {
      User _userData = userCredential.user;
      // Validate phoneNumber
      String phoneNumber = _userData.phoneNumber;
      if (phoneNumber != null && phoneNumber.startsWith("+52")) {
        phoneNumber = phoneNumber.replaceAll("+", "").replaceFirst("52", "");
      }
      // Save new user
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(_userData.uid)
          .set({
        'nombre': _userData.displayName,
        'correo': _userData.email,
        'telefono': phoneNumber,
        'direccion': '',
        'estado': '',
        'municipio': '',
        'photo': {'path': null, 'url': _userData.photoURL},
        'record': '',
        'active': true,
        'completed': false, // We required that user complete their profile
        'type': 'client',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp()
      });
    }

    // Save UID on device
    _prefs.setString('uid', userCredential.user.uid);
    await checkLoginState();

    return Future.value();
  }

  Future<AuthResult> signInWithGoogle() async {
    GoogleSignInAccount result;
    // Trigger the authentication flow
    try {
      result =
          await GoogleSignIn().signIn().catchError((onError) => print(onError));
    } on PlatformException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    // Canceled authentication
    if (result == null) return AuthResult(status: AuthResult.cancelled);

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await result.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return AuthResult(status: AuthResult.ok, credential: credential);
  }

  // Facebook login
  Future<AuthResult> signInWithFacebook() async {
    //TODO Facebook login
    /*try {
      // by default the login method has the next permissions ['email','public_profile']
      AccessToken accessToken = await FacebookAuth.instance.login();
      // get the user data
      //final userData = await FacebookAuth.instance.getUserData();
      //print(userData);
      FacebookAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.token);

      return AuthResult(
          status: AuthResult.ok, credential: facebookAuthCredential);
    } on FacebookAuthException catch (e) {
      print(e.message);
      switch (e.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_progress1:
          print("You have a previous login operation in progress1");
          break;
        case FacebookAuthErrorCode.CANCELLED:
          print("login cancelled");
          break;
        case FacebookAuthErrorCode.FAILED:
          print("login failed");
          break;
      }
    }
*/
    return AuthResult(status: 500, credential: null);
  }

  Future<AuthResult> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    var appleCredential;
    var oauthCredential;

    // Request credential for the currently signed in Apple account.
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
    } on PlatformException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    // Canceled authentication
    if (oauthCredential == null)
      return AuthResult(status: AuthResult.cancelled);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return AuthResult(status: AuthResult.ok, credential: oauthCredential);
  }

  // SignIn With phone
  Future<void> signInWithPhone({String verificationId, String smsCode}) async {
    _loading = true;
    notifyListeners();

    PhoneAuthCredential phoneAuthCredential;
    try {
      phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      await afterSignIn(userCredential);

      return Future.value();
    } on PlatformException catch (err) {
      print(err);
    } catch (err) {
      print(err);
    }

    _loading = false;
    notifyListeners();
  }

  // Phone number authentication
  Future verifyPhoneNumber(String phoneNumber, BuildContext context) {
    return _auth.verifyPhoneNumber(
        phoneNumber: "+52$phoneNumber",
        verificationCompleted: (AuthCredential credential) async {
          // ANDROID ONLY!
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          print(userCredential);
          // redirect
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e);
          return "error";
        },
        codeSent: (String verificationId, int resendToken) {
          Navigator.pop(context);
          launchScreen(context, OPTView.routeName, arguments: {
            'phoneNumber': phoneNumber,
            'verificationId': verificationId
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("retrieval");
        });
  }

  /// Check login status // cookies
  Future<void> checkLoginState() async {
    // Create instance if not initialized
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    // Get logged user data
    if (_prefs.getString('uid') != null) {
      print(_prefs.getString('uid'));
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(_prefs.getString('uid'))
          .get();

      _currentUser = {...userDoc.data() as Map<String, dynamic>, "id": userDoc.id};
      _loggedIn = true;
    }

    // Loading and login
    _loading = false;
    _loadingCurrentUser = false;
    notifyListeners();

    // Promise
    return Future.value();
  }

  /// Check login status // cookies
  Future<Map<String, dynamic>> checkInfo() async {
    // Create instance if not initialized
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    // Get logged user data
    if (_prefs.getString('uid') != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(_prefs.getString('uid'))
          .get();
      _currentUser = {...userDoc.data() as Map<String, dynamic>, "id": userDoc.id};
    }

    print(_currentUser);

    // Promise
    return _currentUser;
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Create instance if not initialized
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    // Assume user is logged in for this example
    String deviceToken = _prefs.getString('device_token');
    String userId = _prefs.getString('uid');

    // User not logged
    if (userId == null || deviceToken != null) return;

    print("Saving token $token to database");

    _prefs.setString('device_token', token);

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(userId)
        .update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  // Close sessión
  void logout() async {
    _loading = true;
    notifyListeners();

    // Clear device data
    _prefs.clear();

    // Close auth session
    await _auth.signOut();

    // local variables
    _loggedIn = false;
    _currentUser = null;
    _loading = false;
    notifyListeners();
  }
}

class AuthResult {
  // status codes
  static const ok = 200;
  static const cancelled = 403;
  static const error = 500;

  final int status;
  final AuthCredential credential;

  AuthResult({this.status, this.credential});

  AuthCredential getCredential() => this.credential;
}
