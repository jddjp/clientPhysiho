import 'dart:async';

import 'package:app_links/app_links.dart';
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
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:clientPhysiho/src/views/opt_view.dart';
import 'package:clientPhysiho/src/views/service_view.dart';
import 'package:clientPhysiho/src/views/splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  Intl.defaultLocale = 'es';

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>(
          create: (_) => LoginProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider<SessionProvider>(
          create: (_) => SessionProvider(),
        ),
      ],
      child: PhysihoApp(),
    ),
  );
}

class PhysihoApp extends StatefulWidget {
  @override
  _PhysihoAppState createState() => _PhysihoAppState();
}

class _PhysihoAppState extends State<PhysihoApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final AppLinks _appLinks = AppLinks();

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  SharedPreferences? _prefs;

  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();

    initialize();
    initializeMessaging();
    initAppLinks();
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {});
  }

  void initializeMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('onMessage: $message');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('onLaunch: $message');
    });

    _firebaseMessaging.requestPermission(
      sound: true,
      alert: true,
      badge: true,
    );

    _firebaseMessaging.getToken().then((String? token) {
      if (!mounted) return;

      context.read<LoginProvider>().saveTokenToDatabase(token);
    });
  }

  Future<void> initAppLinks() async {
    try {
      final String? initialLink =
          await _appLinks.getInitialLinkString();

      if (initialLink != null && initialLink.isNotEmpty) {
        _handleIncomingLink(initialLink);
      }
    } on PlatformException catch (error) {
      debugPrint(
        'Error obteniendo el enlace inicial: $error',
      );
    } catch (error) {
      debugPrint(
        'Error inicializando App Links: $error',
      );
    }

    _sub = _appLinks.stringLinkStream.listen(
      (String link) {
        if (link.isEmpty) return;

        _handleIncomingLink(link);
      },
      onError: (Object error) {
        debugPrint(
          'Error recibiendo deep link: $error',
        );
      },
    );
  }

  void _handleIncomingLink(String link) {
    debugPrint('Deep link recibido: $link');

    final Uri uri;

    try {
      uri = Uri.parse(link);
    } on FormatException catch (error) {
      debugPrint('Deep link inválido: $error');
      return;
    }

    final String? status = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : null;

    final String? id = uri.queryParameters['id'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NavigatorState? nav = navigatorKey.currentState;

      if (nav == null) {
        debugPrint('navigatorKey aún no disponible.');
        return;
      }

      if (status == 'checkout' || uri.host == 'success') {
        nav.pushNamed(CheckoutView.routeName);
        return;
      }

      if (status == 'payment' || id != null) {
        nav.pushNamed(
          CheckTypePayment.routeName,
          arguments: <String, dynamic>{
            'id': id ?? '',
          },
        );
      }
    });
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
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        final Object? args = settings.arguments;

        switch (settings.name) {
          case CheckTypePayment.routeName:
            final Map<String, dynamic> paymentArgs =
                args is Map<String, dynamic>
                    ? args
                    : <String, dynamic>{};

            return MaterialPageRoute(
              builder: (_) => CheckTypePayment(
                item: paymentArgs,
              ),
            );

          case AgendView.routeName:
            return MaterialPageRoute(
              builder: (_) => AgendView(),
            );

          case CreateAccountView.routeName:
            return MaterialPageRoute(
              builder: (_) => CreateAccountView(),
            );

          case OPTView.routeName:
            final Map<String, dynamic> phoneData =
                args is Map<String, dynamic>
                    ? args
                    : <String, dynamic>{};

            return MaterialPageRoute(
              builder: (_) => OPTView(
                phoneData: phoneData,
              ),
            );

          case CompleteProfileView.routeName:
            return MaterialPageRoute(
              builder: (_) => CompleteProfileView(),
            );

          case ServiceView.routeName:
            final String serviceId =
                args is String ? args : '';

            return MaterialPageRoute(
              builder: (_) => ServiceView(
                serviceId: serviceId,
              ),
            );

          case ItemView.routeName:
            final Map<String, dynamic> itemData =
                args is Map<String, dynamic>
                    ? args
                    : <String, dynamic>{
                        'id':
                            _prefs?.getString(
                                  'idpaqueteservicio',
                                ) ??
                                '',
                        'idservice':
                            _prefs?.getString(
                                  'idservicio',
                                ) ??
                                '',
                      };

            return PageRouteBuilder(
              pageBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return ItemView(item: itemData);
              },
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.ease,
                    ),
                  ),
                  child: child,
                );
              },
            );

          case CheckoutView.routeName:
            return MaterialPageRoute(
              builder: (_) => CheckoutView(),
            );

          case LoginView.routeName:
            return MaterialPageRoute(
              builder: (_) => LoginView(),
            );

          case HomeView.routeName:
            final String agendaValue =
                args is String ? args : '';

            return MaterialPageRoute(
              builder: (_) => HomeView(
                agendSetView: agendaValue,
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => SplashView(),
            );
        }
      },
    );
  }
}

class PushNotificationMessage {
  final String title;
  final String body;

  PushNotificationMessage({
    required this.title,
    required this.body,
  });
}