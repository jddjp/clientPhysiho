// @dart=2.9
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AgendView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'agend';
  AgendView({Key key}) : super(key: key);

  @override
  _AgendViewState createState() => _AgendViewState();
}

class _AgendViewState extends State<AgendView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/fondoph.png"),
              fit: BoxFit.cover)),
      child: MyHomePage(title: 'Agenda'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  final sesionrecord = new SessionProvider();
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  final sessions = new SessionProvider();
  String _valueChanged = '';
  int flat = 0;
  Map<DateTime, List> _eventsFisiho = {};
  var helper = [];
  final _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();
    DateTime f = DateTime(2021, 01, 01);
    //print(f);
    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        'Event A0',
        'Event B0',
        'Event C0'
      ],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): [
        'Event A2',
        'Event B2',
        'Event C2',
        'Event D2'
      ],
      // _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      // _selectedDay.subtract(Duration(days: 10)): [
      //   'Event A4',
      //   'Event B4',
      //   'Event C4'
      // ],
      // _selectedDay.subtract(Duration(days: 4)): [
      //   'Event A5',
      //   'Event B5',
      //   'Event C5'
      // ],
      // _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      // // _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      // _selectedDay.add(Duration(days: 1)): [
      //   'Event A8',
      //   'Event B8',
      //   'Event C8',
      //   'Event D8'
      // ],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    //print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    //print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    //print('CALLBACK: _onCalendarCreated');
  }

  Map<DateTime, List> _buildItems(List<dynamic> elements) {
    //someObjects.sort((a, b) => a.someProperty.compareTo(b.someProperty));
    //print(elements);
    print(elements.length);
    elements.forEach((element) {
      if (!helper.contains(element['date'])) {
        helper.add(element['date']);
      }
    });
    print('list date´s');

    helper.toList().asMap().forEach((key, value) {
      print('helper');
      print(elements);
      final dateA = DateFormat('yyyy-MM-dd').parse(value);
      final dateS = DateFormat('yyyy-MM-dd').parse(value);
      var item = [];
      elements.forEach((element) {
        print('list element');
        if (element['date'] == value) {
          print('foreach element');
          //print('coincide');
          //print(key);
          print(value);
          //print(element);
          String s = 'Servicio: ' + element['serviceName'].toString();
          String p = 'Paquete: ' + element['packageName'].toString();
          String c = "Horario: " + element['hours'].toString();
          String dataInfo = 'Cita \n' + s + '\n' + p + '\n' + c;
          //print(dataInfo);
          item.add(dataInfo);
          //_eventsFisiho.addAll({dateA: item});
        }
      });
      _eventsFisiho.addAll({dateA: item});
      print(dateA);
      print(item);
    });
    /*int i = 0;
    while (i < elements.length) {
      final dateA = DateFormat('yyyy-MM-dd').parse(elements[i]['date']);
      final dateS = DateFormat('yyyy-MM-dd').parse(elements[i]['date']);
      //print("Entrando en while");
      if (dateA == dateS) {
        //print("Entrando en if de while");

        String s = 'Servicio: ' + elements[i]['serviceName'].toString();
        String p = 'Paquete: ' + elements[i]['packageName'].toString();
        String c = "Horario: " + elements[i]['hours'].toString();
        String dataInfo = 'Cita \n' + s + '\n' + p + '\n' + c;
        //print('data List :');
        // helper.add({element['date']});

        /*_eventsFisiho.addAll({
          dateA: [dataInfo, dataInfo]
        });*/
      }
      i++;
    }*/
    /*  elements.forEach((element) {
      print(element);
      print("imprimiendo elementos");
      //print(element['date']);
      final date = DateFormat('yyyy-MM-dd').parse(element['date']);
      //print(date);
      DateTime f2 = DateTime(2021, 01, 01);

      String s = 'Servicio: ' + element['serviceName'].toString();
      String p = 'Paquete: ' + element['packageName'].toString();
      String c = "Horario: " + element['hours'].toString();
      String dataInfo = 'Cita \n' + s + '\n' + p + '\n' + c;
      //print('data List :');
      // helper.add({element['date']});

      _eventsFisiho.addAll({
        date: [dataInfo, dataInfo]
      }); */
    //});
    //print('list helper : ${helper}');
    //print('list events ${_eventsFisiho}');

    return _eventsFisiho;
  }

  @override
  Widget build(BuildContext context) {
    print('init');
  
          print(context.watch<LoginProvider>().currentUser['id'] );
             final idUser = context.watch<LoginProvider>().currentUser['id'];

 

    return (context.watch<LoginProvider>().isLoggedIn() &&
            context.watch<LoginProvider>().currentUser['nombre'] != null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: pantoneFour,
              title: Center(child: Text(widget.title)),
            ),
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/fondoph.png"),
                      fit: BoxFit.cover)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // Switch out 2 lines below to play with TableCalendar's settings
                  //-----------------------
                  _buildTableCalendar(idUser),
                  // _buildTableCalendarWithBuilders(),
                  const SizedBox(height: 8.0),
                  _buildButtons(),
                  const SizedBox(height: 8.0),
                  Expanded(child: _buildEventList()),
                ],
              ),
            ))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: pantoneFour,
              title: Center(child: Text(widget.title)),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    backgroundBlendMode: BlendMode.color,
                    image: DecorationImage(
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.8), BlendMode.dstATop),
                        image: new AssetImage('assets/images/fondoph.png'),
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          title: Text(
                            "Disfruta de nuestros servicios agenda y regístrate",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Franklin Gothic',
                                fontWeight: fontSemibold),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            launchScreen(context, LoginView.routeName);
                          },
                        ),
                        ListTile(
                          title: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: pantoneFive,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text(
                              "Click aqui para registrarte",
                              style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 20,
                                  fontFamily: 'Franklin Gothic',
                                  fontWeight: fontSemibold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () {
                            launchScreen(context, LoginView.routeName);
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ));
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar(dynamic idUser) {
    print('user build table');
    print(idUser);
    _valueChanged = context.watch<LoginProvider>().isLoggedIn() &&
            context.watch<LoginProvider>().currentUser['id'] != null
        ? flat == ''
            ? context.watch<LoginProvider>().currentUser['id']
            : _valueChanged
        : '';

    final t = sesionrecord.getSessionUser(idUser);

    //print("buil calendar viendfo q imprime");
    return FutureBuilder(
      future: t,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //print(snapshot.hasData);
        //print("imprimiendo snap shap XD");
        if (snapshot.hasData) {
          //imprimiendo la fila y el dato que se necesito
          //print(snapshot.data);
          return TableCalendar(
            locale: 'es',
            calendarController: _calendarController,
            events: _buildItems(snapshot.data),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              selectedColor: pantoneEleven,
              todayColor: pantoneOne,
              markersColor: Colors.red[700],
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonTextStyle:
                  TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
              formatButtonDecoration: BoxDecoration(
                color: pantoneEleven,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            onDaySelected: _onDaySelected,
            onVisibleDaysChanged: _onVisibleDaysChanged,
            onCalendarCreated: _onCalendarCreated,
          );
        } else {
          return TableCalendar(
            locale: 'es',
            calendarController: _calendarController,
            events: _events,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              selectedColor: pantoneEleven,
              todayColor: pantoneOne,
              markersColor: Colors.red[700],
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonTextStyle:
                  TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
              formatButtonDecoration: BoxDecoration(
                color: pantoneEleven,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            onDaySelected: _onDaySelected,
            onVisibleDaysChanged: _onVisibleDaysChanged,
            onCalendarCreated: _onCalendarCreated,
          );
        }
      },
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    sesionrecord
        .getSessionUser(context.watch<LoginProvider>().currentUser['id']);
    //print(sesionrecord
    // .getSessionUser(context.watch<LoginProvider>().currentUser['id']));
    //print("buil calendar viendfo q impri,me");
    return FutureBuilder(
      future: sesionrecord
          .getSessionUser(context.watch<LoginProvider>().currentUser['id']),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return TableCalendar(
            locale: 'es',
            calendarController: _calendarController,
            events: _events,
            initialCalendarFormat: CalendarFormat.month,
            formatAnimation: FormatAnimation.slide,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            availableGestures: AvailableGestures.all,
            availableCalendarFormats: const {
              CalendarFormat.month: '',
              CalendarFormat.week: '',
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
              holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
            ),
            headerStyle: HeaderStyle(
              centerHeaderTitle: true,
              formatButtonVisible: false,
            ),
            builders: CalendarBuilders(
              selectedDayBuilder: (context, date, _) {
                return FadeTransition(
                  opacity:
                      Tween(begin: 0.0, end: 1.0).animate(_animationController),
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                    color: Colors.deepOrange[300],
                    width: 100,
                    height: 100,
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0),
                    ),
                  ),
                );
              },
              todayDayBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                  color: Colors.amber[400],
                  width: 100,
                  height: 100,
                  child: Text(
                    '${date.day}',
                    style: TextStyle().copyWith(fontSize: 16.0),
                  ),
                );
              },
              markersBuilder: (context, date, events, holidays) {
                final children = <Widget>[];

                if (events.isNotEmpty) {
                  children.add(
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    ),
                  );
                }

                if (holidays.isNotEmpty) {
                  children.add(
                    Positioned(
                      right: -2,
                      top: -2,
                      child: _buildHolidaysMarker(),
                    ),
                  );
                }

                return children;
              },
            ),
            onDaySelected: (date, events, holidays) {
              _onDaySelected(date, events, holidays);
              _animationController.forward(from: 0.0);
            },
            onVisibleDaysChanged: _onVisibleDaysChanged,
            onCalendarCreated: _onCalendarCreated,
          );
        } else {
          return Container(
            child: Text('no data'),
          );
        }
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    final dateTime = _events.keys.elementAt(_events.length - 2);

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              child: Text('Mes'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            ElevatedButton(
              child: Text('2 semanas'),
              onPressed: () {
                setState(() {
                  _calendarController
                      .setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            ElevatedButton(
              child: Text('Semana'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}
