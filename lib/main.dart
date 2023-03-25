// @dart=2.9
import 'dart:async';
import 'dart:io';

import 'package:clientPhysiho/src/components/check_type_payment.dart';
import 'package:clientPhysiho/src/config/theme.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/providers/cart_provider.dart';
import 'package:clientPhysiho/src/providers/location_provider.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/views/about_view.dart';
import 'package:clientPhysiho/src/views/address_confirmation_view.dart';
import 'package:clientPhysiho/src/views/agend_view.dart';
import 'package:clientPhysiho/src/views/business_view.dart';
import 'package:clientPhysiho/src/views/cart_view.dart';
import 'package:clientPhysiho/src/views/category_view.dart';
import 'package:clientPhysiho/src/views/checkout_view.dart';
import 'package:clientPhysiho/src/views/complete_profile_view.dart';
import 'package:clientPhysiho/src/views/create_account_view.dart';
import 'package:clientPhysiho/src/views/department_view.dart';
import 'package:clientPhysiho/src/views/home_view.dart';
import 'package:clientPhysiho/src/views/item_view.dart';
import 'package:clientPhysiho/src/views/loading_view.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:clientPhysiho/src/views/opt_view.dart';
import 'package:clientPhysiho/src/views/order_detail_view.dart';
import 'package:clientPhysiho/src/views/order_item_view.dart';
import 'package:clientPhysiho/src/views/payment_view.dart';
import 'package:clientPhysiho/src/views/service_view.dart';
import 'package:clientPhysiho/src/views/splash.dart';
import 'package:clientPhysiho/src/views/tracking_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MultiProvider(
            providers: [
              ChangeNotifierProvider<LoginProvider>(
                  create: (_) => LoginProvider()),
              //ChangeNotifierProvider<MessagingProvider>(create: (_) => MessagingProvider()),
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
      _navigateToDetail(message.data);
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

  _navigateToDetail(Map<String, dynamic> message) {
    if (message['data']['type'] == 'business') {
      launchScreen(context, BusinessView.routeName,
          arguments: message['data']['id']);
    }
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
          // department view
          case DepartmentView.routeName:
            return MaterialPageRoute(
                builder: (_) => DepartmentView(department: args));
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
          // cart view
          case CartView.routeName:
            return MaterialPageRoute(builder: (_) => CartView());
            break;
          // category view
          case CategoryView.routeName:
            return MaterialPageRoute(
                builder: (_) => CategoryView(categoryName: args));
            break;
          // checkout view
          case CheckoutView.routeName:
            return MaterialPageRoute(builder: (_) => CheckoutView());
            break;
          //address confirmation view
          case AddressConfirmation.routeName:
            return MaterialPageRoute(builder: (_) => AddressConfirmation());
            break;
          // payment view
          case PaymentView.routeName:
            return MaterialPageRoute(builder: (_) => PaymentView());
            break;
          // tracking view
          case TrackingView.routeName:
            return MaterialPageRoute(
                builder: (_) => TrackingView(orderId: args));
            break;
          case OrderDetail.routeName:
            return MaterialPageRoute(builder: (_) => OrderDetail(order: args));
            break;
          case OrderItemView.routeName:
            return MaterialPageRoute(builder: (_) => OrderItemView(item: args));
            break;
          case AboutPage.routeName:
            return MaterialPageRoute(builder: (_) => AboutPage());
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
              /*if (_error) {
                return Container(
                  child: Text("Error en Firebase"),
                );
              }*/

              /*if (!_initialized) {
                return LoadingView(
                    sourceLoading: "Cargando recursos generales...");
              } else if (context
                  .watch<LoginProvider>()
                  .isLoadingCurrentUser()) {
                return LoadingView(
                    sourceLoading: "Cargando información del usuario...");
              } else if (!context
                  .watch<LocationProvider>()
                  .isPermissionChecked()) {
                return LoadingView(sourceLoading: "Cargando ubicación...");
              }*/

              if (_prefs == null) {
                return LoadingView(
                    sourceLoading: "Cargando recursos generales...");
              }

              /*if (_prefs.getBool('locationPermission') != true &&
                  !context.watch<LocationProvider>().hasPermission()) {
                print("==============LOCATION_VIEW=====================");
                return LocationView();
                // if orderInProgress == logged_out then redirect to cart_view
              } else {*/
              // Go to Home
              print(_prefs.getBool('locationPermission'));
              print("==============HOME_VIEW=====================");
              return SplashView();
              //}

              // User logged in
              /*if (context.watch<LoginProvider>().isLoggedIn()) {
                // User no completed
                if (!context.watch<LoginProvider>().isCompleted()) {
                  print("==============COMPLETE_VIEW=====================");
                  return CompleteProfileView();
                } else if (!context.watch<LocationProvider>().hasPermission()) {
                  print("==============LOCATION_VIEW=====================");
                  return LocationView();
                } else {
                  // Go to Home
                  print("==============HOME_VIEW=====================");
                  return HomeView();
                }
              } else {
                print("==============LOGIN_VIEW=====================");
                return LoginView();
              }*/
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
