
import 'package:clientPhysiho/src/config/colors.dart';
import 'package:clientPhysiho/src/config/constants.dart';
import 'package:clientPhysiho/src/helpers/extension_helper.dart';
import 'package:clientPhysiho/src/providers/login_provider.dart';
import 'package:clientPhysiho/src/providers/sessions_provider.dart';
import 'package:clientPhysiho/src/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendView extends StatefulWidget {
  // Route name for this view
  static const routeName = 'agend';

  AgendView({Key? key}) : super(key: key);

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
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final sesionrecord = SessionProvider();
  final sessions = SessionProvider();
  String _valueChanged = '';
  int flat = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};
  List<String> _selectedEvents = const [];
  final Map<DateTime, List<String>> _eventsFisiho = {};
  final List<String> helper = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDay = today;
    _events = {
      today.subtract(const Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
      today.subtract(const Duration(days: 27)): ['Event A1'],
      today.subtract(const Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
    };
    _selectedEvents = _eventsForDay(_selectedDay!);
  }

  List<String> _eventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? const [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _eventsForDay(selectedDay);
    });
  }

  Map<DateTime, List<String>> _buildItems(List<dynamic> elements) {
    _eventsFisiho.clear();
    helper.clear();

    for (final element in elements) {
      final dateValue = element['date']?.toString();
      if (dateValue != null && !helper.contains(dateValue)) {
        helper.add(dateValue);
      }
    }

    for (final value in helper) {
      final dateA = DateFormat('yyyy-MM-dd').parse(value);
      final normalized = DateTime(dateA.year, dateA.month, dateA.day);
      final item = <String>[];

      for (final element in elements) {
        if (element['date']?.toString() == value) {
          final s = 'Servicio: ${element['serviceName'] ?? ''}';
          final p = 'Paquete: ${element['packageName'] ?? ''}';
          final c = 'Horario: ${element['hours'] ?? ''}';
          final d = 'Ubicacion: ${element['location'] ?? ''}';
          item.add('Cita\n$s\n$p\n$c\n$d');
        }
      }

      _eventsFisiho[normalized] = item;
    }

    return _eventsFisiho;
  }

  @override
  Widget build(BuildContext context) {
    print('init');

    //print(context.watch<LoginProvider>().currentUser['id']);
    //final idUser = context.watch<LoginProvider>().currentUser['id'];

    final currentUser = context.watch<LoginProvider>().currentUser ?? {};
    return (context.watch<LoginProvider>().isLoggedIn() &&
            (currentUser['nombre'] ?? '').toString().isNotEmpty
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: pantoneFour,
              title: Center(child: Text(widget.title, style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontFamily: 'Franklin Gothic'),)),
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
                  _buildTableCalendar(currentUser['id'] ?? ''),
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
    final id = idUser?.toString() ?? '';

    final isLoggedIn = context.watch<LoginProvider>().isLoggedIn();
    final userId = context.watch<LoginProvider>().currentUser?['id']?.toString() ?? '';
    final selectedUserId = isLoggedIn && userId.isNotEmpty
        ? (flat == 0 ? userId : _valueChanged)
        : '';

    _valueChanged = selectedUserId;

    final t = sesionrecord.getSessionUser(id);

    return FutureBuilder(
      future: t,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final data = snapshot.data is List ? snapshot.data as List : const <dynamic>[];
        final events = _buildItems(data);

        return Column(
          children: [
            TableCalendar<String>(
              locale: 'es',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                final normalized = DateTime(day.year, day.month, day.day);
                return events[normalized] ?? const <String>[];
              },
              onDaySelected: _onDaySelected,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: pantoneEleven,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: pantoneOne,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red[700],
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Cargando citas para sesiones '),
                  SizedBox(
                    height: size_chargin,
                    width: size_chargin,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Mes'),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
                });
              },
            ),
            ElevatedButton(
              child: const Text('2 semanas'),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay;
                });
              },
            ),
            ElevatedButton(
              child: const Text('Semana'),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay;
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
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}
