import 'dart:convert';
import 'dart:math';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide AuthorizationStatus;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/views/opt_view.dart';
import 'package:crypto/crypto.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

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
  late FirebaseAuth _auth;
  late SharedPreferences _prefs;
  Map<String, dynamic>? _currentUser;

  bool _loggedIn = false;
  bool _loading = false;
  bool _loadingCurrentUser = true;

  // Public access to current user data
  Map<String, dynamic>? get currentUser => _currentUser;

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

  bool isCompleted() => _currentUser?['completed'] == true;

  // Main login function
  Future<dynamic> login(String type) async {
    print("============LOGIN" + type);
    _loading = true;
    notifyListeners();

    final AuthResult result =
        type == 'google' ? await signInWithGoogle() : await signInWithApple();

    if (result.status == AuthResult.ok) {
      try {
        final credential = result.credential;
        if (credential == null) {
          throw FirebaseAuthException(code: 'credential-null');
        }
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        //print("Validamos nombre"+result.fullName);
        return afterSignIn(userCredential, name: result.fullName);
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          msg: 'Error: ${e.message ?? 'No fue posible iniciar sesión'}',
        );
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
    final result = await FlutterWebAuth2.authenticate(
        url: "https://fisioterapia-cfb53.web.app",
        callbackUrlScheme: "physiho");

    // Extract status from resulting url
    final params = Uri.parse(result).queryParameters;
    final status = int.tryParse(params['status'] ?? '') ?? AuthResult.error;

    // Success
    if (status == AuthResult.ok) {
      final uid = params['uid'];
      if (uid != null) {
        _prefs.setString('uid', uid);
      }
      await checkLoginState();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> afterSignIn(UserCredential userCredential,
      {String? name, String? phone}) async {
    print(userCredential);
    _loadingCurrentUser = true;
    notifyListeners();
    // Register in firestore if is a new user
    if (userCredential.additionalUserInfo?.isNewUser == true) {
      final User? _userData = userCredential.user;
      if (_userData == null) {
        return;
      }
      // Validate phoneNumber
      String phoneNumber = _userData.phoneNumber ?? '';
      if (phoneNumber.startsWith("+52")) {
        phoneNumber = phoneNumber.replaceAll("+", "").replaceFirst("52", "");
      }
      // Save new user
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(_userData.uid)
          .set({
        'nombre': name ?? _userData.displayName,
        'correo': _userData.email,
        'telefono': phone ?? phoneNumber,
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

    final currentUser = userCredential.user;
    if (currentUser == null) {
      return;
    }

    _prefs.setString('uid', currentUser.uid);
    await checkLoginState();

    try {
      final String? messagingToken =
          await FirebaseMessaging.instance.getToken();
      await saveTokenToDatabase(messagingToken);
    } on FirebaseException catch (error) {
      debugPrint('No fue posible registrar el token de mensajerÃ­a: $error');
    }

    return Future.value();
  }

  Future<AuthResult> signInWithGoogle() async {
    GoogleSignInAccount? result;
    try {
      result = await GoogleSignIn().signIn();
    } on PlatformException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    if (result == null) {
      return AuthResult(
          status: AuthResult.cancelled, credential: null, message: 'cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await result.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return AuthResult(status: AuthResult.ok, credential: credential);
  }

  Future<AuthResult> signInWithApple() async {
    String message = "";
    final result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    if (result.status == AuthorizationStatus.authorized) {
      final appleIdCredential = result.credential;
      if (appleIdCredential == null) {
        return AuthResult(
            status: AuthResult.error, credential: null, message: message);
      }
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: String.fromCharCodes(appleIdCredential.identityToken ?? []),
        accessToken:
            String.fromCharCodes(appleIdCredential.authorizationCode ?? []),
      );
      print(appleIdCredential);
      print("valida nombre");
      print(
          '${appleIdCredential.fullName?.givenName ?? ''} ${appleIdCredential.fullName?.familyName ?? ''}');
      return AuthResult(
          status: AuthResult.ok,
          credential: credential,
          fullName:
              '${appleIdCredential.fullName?.givenName ?? ''} ${appleIdCredential.fullName?.familyName ?? ''}');
    }
    return AuthResult(
        status: AuthResult.error, credential: null, message: message);
  }

  // SignIn With phone
  Future<void> signInWithPhone(
      {String? verificationId, String? smsCode}) async {
    _loading = true;
    notifyListeners();

    PhoneAuthCredential phoneAuthCredential;
    try {
      if (verificationId == null || smsCode == null) {
        throw const FormatException('verificationId and smsCode are required');
      }
      phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      await afterSignIn(userCredential);

      return Future.value();
    } on PlatformException catch (err) {
      final String errorMessage =
          err.message ?? err.details?.toString() ?? err.code;

      Fluttertoast.showToast(
        msg: errorMessage.isNotEmpty
            ? errorMessage
            : 'Ocurrió un error al validar el código',
      );

      _loading = false;
    } catch (err) {
      _loading = false;
      Fluttertoast.showToast(msg: 'Error:' + err.toString());
    }

    _loading = false;
    notifyListeners();
  }

  // Phone number authentication
  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context) {
    return _auth.verifyPhoneNumber(
      phoneNumber: "+52$phoneNumber",
      verificationCompleted: (AuthCredential credential) async {
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        print(userCredential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.pop(context);
        launchScreen(context, OPTView.routeName, arguments: {
          'phoneNumber': phoneNumber,
          'verificationId': verificationId
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("retrieval");
      },
    );
  }

  /// Check login status // cookies
  Future<void> checkLoginState() async {
    final uid = _prefs.getString('uid');
    if (uid != null && uid.isNotEmpty) {
      print(uid);

      final userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        _currentUser = {
          ...userDoc.data() as Map<String, dynamic>,
          "id": userDoc.id
        };
        _loggedIn = true;
      } else {
        await FirebaseFirestore.instance.collection('customers').doc(uid).set({
          'name': '',
          'email': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        final newUserDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(uid)
            .get();

        _currentUser = {
          ...newUserDoc.data() as Map<String, dynamic>,
          "id": newUserDoc.id
        };
        _loggedIn = true;
      }
    }
    // Loading and login
    _loading = false;
    _loadingCurrentUser = false;
    notifyListeners();

    // Promise
    return Future.value();
  }

  /// Check login status // cookies
  Future<Map<String, dynamic>?> checkInfo() async {
    final uid = _prefs.getString('uid');
    if (uid != null && uid.isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .get();
      _currentUser = {
        ...userDoc.data() as Map<String, dynamic>,
        "id": userDoc.id
      };
    }

    print(_currentUser);

    return _currentUser;
  }

  Future<void> saveTokenToDatabase(String? token) async {
    final String? userId = _prefs.getString('uid');

    // User not logged
    if (token == null || userId == null) {
      return;
    }

    print('Saving token $token to database');

    await _prefs.setString('device_token', token);

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
  final AuthCredential? credential;
  final String message;
  final String? fullName;

  AuthResult(
      {required this.status,
      this.credential,
      this.message = 'success',
      this.fullName});

  AuthCredential? getCredential() => credential;
}
