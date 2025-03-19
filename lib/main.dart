// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:clientPhysiho/src/components/check_type_payment.dart';
import 'package:clientPhysiho/src/config/theme.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/agend_view.dart';
import 'package:clientPhysiho/src/views/checkout_view.dart';
import 'package:clientPhysiho/src/views/complete_profile_view.dart';
import 'package:clientPhysiho/src/views/create_account_view.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:clientPhysiho/src/views/item_view.dart';
import 'package:clientPhysiho/src/views/loading_view.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:clientPhysiho/src/views/opt_view.dart';
import 'package:clientPhysiho/src/views/service_view.dart';
import 'package:clientPhysiho/src/views/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
   Intl.defaultLocale = 'es'; // Configura el idioma a español
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MultiProvider(
            providers: [
              
              ChangeNotifierProvider<LoginProvider>(
                  create: (_) => LoginProvider()),
              ChangeNotifierProvider<CartProvider>(
                  create: (_) => CartProvider()),
              ChangeNotifierProvider<LocationProvider>(
                  create: (_) => LocationProvider())
            ],
            child: PhysihoApp(),
          )));
}

class PhysihoApp extends StatefulWidget {
  @override
  _PhysihoAppState createState() => _PhysihoAppState();
}

class _PhysihoAppState extends State<PhysihoApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  SharedPreferences _prefs;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  void initializeMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      if (Platform.isAndroid) {
        PushNotificationMessage(
          title: message.data['notification']['title'],
          body: message.data['notification']['body'],
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch: $message");
      //_navigateToDetail(message.data);
    });
    _firebaseMessaging.requestPermission(
      sound: true,
      alert: true,
      badge: true,
    );
    //TODO Ios register
    FirebaseMessaging.instance.getToken().then((value) {
      String token = value;
      context.read<LoginProvider>().saveTokenToDatabase(token);
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
    //initializeFlutterFire();
    initializeMessaging();
  }

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Physiho App',
      theme: getThemeData(),
      supportedLocales: [Locale('en'), Locale('es')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      onGenerateRoute: (RouteSettings settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case AgendView.routeName:
            return MaterialPageRoute(builder: (_) => AgendView());
            break;
          // create account view
          case CreateAccountView.routeName:
            return MaterialPageRoute(builder: (_) => CreateAccountView());
            break;
          // opt view
          case OPTView.routeName:
            return MaterialPageRoute(builder: (_) => OPTView(phoneData: args));
            break;
          // complete profile view
          case CompleteProfileView.routeName:
            return MaterialPageRoute(builder: (_) => CompleteProfileView());
            break;

          // business view
          case ServiceView.routeName:
            return MaterialPageRoute(
                builder: (_) => ServiceView(serviceId: args));
            break;
          // agend view
          case AgendView.routeName:
            return MaterialPageRoute(builder: (_) => AgendView());
            break;
          case CheckTypePayment.routeName:
            return MaterialPageRoute(
                builder: (_) => CheckTypePayment(
                      item: args,
                    ));
            break;
          // item view
          case ItemView.routeName:
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ItemView(
                  item: args != null
                      ? args
                      : {
                          'id': _prefs.getString('idpaqueteservicio'),
                          'idservice': _prefs.getString('idservicio')
                        }),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = Offset(0.0, 1.0);
                var end = Offset.zero;
                var curve = Curves.ease;

                var tween = Tween(begin: begin, end: end);
                var curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: curve,
                );

                return SlideTransition(
                  position: tween.animate(curvedAnimation),
                  child: child,
                );
              },
            );
            break;


          // checkout view
          case CheckoutView.routeName:
            return MaterialPageRoute(builder: (_) => CheckoutView());
            break;


          case LoginView.routeName:
            return MaterialPageRoute(builder: (_) => LoginView());
            break;
          case HomeView.routeName:
            return MaterialPageRoute(
                builder: (_) => HomeView(
                      agendSetView: args,
                    ));
            break;
          default:
            return MaterialPageRoute(builder: (context) {
              if (_prefs == null) {
                return LoadingView(
                    sourceLoading: "Cargando recursos generales...");
              }
              // Go to Home
              print(_prefs.getBool('locationPermission'));
              print("==============HOME_VIEW=====================");
              return SplashView();
            });
        }
      },
    );
  }
}

class PushNotificationMessage {
  final String title;
  final String body;

  PushNotificationMessage({
    this.title,
    this.body,
  });
}
