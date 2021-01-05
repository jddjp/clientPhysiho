import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/views/opt_view.dart';

class LoginProvider with ChangeNotifier {

  FirebaseAuth _auth;
  SharedPreferences _prefs;
  Map<String,dynamic> _currentUser;

  bool _loggedIn = false;
  bool _loading = false;
  bool _loadingCurrentUser = true;

  // Public access to current user data
  Map<String,dynamic> get currentUser => _currentUser;

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

  bool isCompleted() => _currentUser != null ? _currentUser['completed'] == true : false;

  // Main login function
  void login(String type) async {
    _loading = true;
    notifyListeners();

    final AuthResult result = type == 'google'
        ? await signInWithGoogle()
        : await signInWithFacebook();

    if (result.status == AuthResult.ok) {
      try {
        UserCredential userCredential =
            await _auth.signInWithCredential(result.credential);
        return afterSignIn(userCredential);
      } on FirebaseAuthException catch (e) {
        print(e);
      }
    } else if (result.status == AuthResult.cancelled) {
      print("login canceled");
    } else {
      print("login error");
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
          'photo': {
            'path': null,
            'url': _userData.photoURL
          },
          'record': {
            'path': null,
            'url': null
          },
          'active': 1,
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
    if (result == null) 
      return AuthResult(status: AuthResult.cancelled);

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
    try {
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
          case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
            print("You have a previous login operation in progress");
            break;
          case FacebookAuthErrorCode.CANCELLED:
            print("login cancelled");
            break;
          case FacebookAuthErrorCode.FAILED:
            print("login failed");
            break;
      }
    }

    return AuthResult(
        status: 500, credential: null);
  }

  // SignIn With phone
  Future<void> signInWithPhone({String verificationId, String smsCode}) async {
    _loading = true;
    notifyListeners();

    PhoneAuthCredential phoneAuthCredential;
    try {
      phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, 
        smsCode: smsCode
      );
      // Sign the user in (or link) with the credential
      UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      
      await afterSignIn(userCredential);

      return Future.value();
    } on PlatformException catch(err) {
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
    if (_prefs == null) 
      _prefs = await SharedPreferences.getInstance();

    // Get logged user data
    if (_prefs.getString('uid') != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customers').doc(_prefs.getString('uid')).get();
      _currentUser = {
        ...userDoc.data(),
        "id": userDoc.id
      };
      _loggedIn = true;
    }

    // Loading and login
    _loading = false;
    _loadingCurrentUser = false;
    notifyListeners();

    // Promise
    return Future.value();
  }

  Future<void> saveTokenToDatabase(String token) async {

    // Create instance if not initialized
    if (_prefs == null) 
      _prefs = await SharedPreferences.getInstance();

    // Assume user is logged in for this example
    String deviceToken = _prefs.getString('device_token');
    String userId = _prefs.getString('uid');

    // User not logged
    if (userId == null || deviceToken != null)
      return;

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