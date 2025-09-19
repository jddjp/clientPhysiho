// @dart=2.9
import 'dart:async';
import 'dart:io';
import 'package:clientPhysiho/src/components/check_type_payment.dart';
import 'package:clientPhysiho/src/config/theme.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
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
import 'package:uni_links/uni_links.dart';

Future<void> main() async {
  Intl.defaultLocale = 'es';
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
      ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
      ChangeNotifierProvider<LocationProvider>(create: (_) => LocationProvider()),
      ChangeNotifierProvider<SessionProvider>(create: (_) => SessionProvider()),

    ],
    child: PhysihoApp(),
  )));
}

class PhysihoApp extends StatefulWidget {
  @override
  _PhysihoAppState createState() => _PhysihoAppState();
}

class _PhysihoAppState extends State<PhysihoApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  SharedPreferences _prefs;
  StreamSubscription _sub;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    initialize();
    initializeMessaging();
    initUniLinks();
  }

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  void initializeMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch: $message");
    });

    _firebaseMessaging.requestPermission(sound: true, alert: true, badge: true);
    _firebaseMessaging.getToken().then((value) {
      context.read<LoginProvider>().saveTokenToDatabase(value);
    });
  }

  Future<void> initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) _handleIncomingLink(initialLink);
    } on PlatformException {}

    _sub = getLinksStream().listen((String link) {
      if (link != null) _handleIncomingLink(link);
    }, onError: (err) {});
  }


  void _handleIncomingLink(String link) {
    print('🔗 Deep link recibido: $link');
    Uri uri = Uri.parse(link);
    String status = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    String id = uri.queryParameters['id'];
    if (uri.host == 'success') {



        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState.pushNamed(
              CheckoutView.routeName
            );
          }else {
            print("❗ navigatorKey aún no disponible.");
          }
        });
      } else if (uri.host == 'success') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState.pushNamed(
              CheckTypePayment.routeName,
              arguments: id,
            );
          }else {
            print("❗ navigatorKey aún no disponible.");
          }
        });
      } else if (uri.host == 'success') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState.pushNamed(
              CheckTypePayment.routeName,
              arguments: id,
            );
          }else {
            print("❗ navigatorKey aún no disponible.");
          }
        });
      }

  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Physiho App',
      theme: getThemeData(),
      supportedLocales: [Locale('en'), Locale('es')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case CheckTypePayment.routeName:
            return MaterialPageRoute(builder: (_) => CheckTypePayment(item: args));
          case AgendView.routeName:
            return MaterialPageRoute(builder: (_) => AgendView());
          case CreateAccountView.routeName:
            return MaterialPageRoute(builder: (_) => CreateAccountView());
          case OPTView.routeName:
            return MaterialPageRoute(builder: (_) => OPTView(phoneData: args));
          case CompleteProfileView.routeName:
            return MaterialPageRoute(builder: (_) => CompleteProfileView());
          case ServiceView.routeName:
            return MaterialPageRoute(builder: (_) => ServiceView(serviceId: args));

          case ItemView.routeName:
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ItemView(
                item: args ?? {
                  'id': _prefs.getString('idpaqueteservicio'),
                  'idservice': _prefs.getString('idservicio'),
                },
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.ease)),
                  child: child,
                );
              },
            );
          case CheckoutView.routeName:
            return MaterialPageRoute(builder: (_) => CheckoutView());
          case LoginView.routeName:
            return MaterialPageRoute(builder: (_) => LoginView());
          case HomeView.routeName:
            return MaterialPageRoute(builder: (_) => HomeView(agendSetView: args));
          default:
            return MaterialPageRoute(
              builder: (context) {
                if (_prefs == null) {
                  return LoadingView(sourceLoading: "Cargando recursos generales...");
                }
                return SplashView();
              },
            );
        }
      },
    );
  }
}

class PushNotificationMessage {
  final String title;
  final String body;

  PushNotificationMessage({this.title, this.body});
}
