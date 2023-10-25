import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime firstDay = DateTime.now();
  late SharedPreferences prefs;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getInt('dday');

    if (firstTime != null) {
      setState(() {
        firstDay = DateTime.fromMillisecondsSinceEpoch(firstTime);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DDay(
              onHeartPressed: onHeartPressed,
              firstDay: firstDay,
            ),
            _CoupleImage(),
          ],
        ),
      ),
    );
  }

  void onHeartPressed() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white,
            height: 300,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (DateTime date) async {
                await prefs.setInt('dday', date.millisecondsSinceEpoch);
                setState(() {
                  firstDay = date;
                });
              },
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }
}

class _DDay extends StatelessWidget {
  final GestureTapCallback onHeartPressed;
  final DateTime firstDay;

  const _DDay({
    required this.onHeartPressed,
    required this.firstDay,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();

    return Column(children: [
      const SizedBox(height: 16.0),
      Text(
        'U&I',
        style: textTheme.displayLarge,
      ),
      const SizedBox(height: 16.0),
      Text(
        '우리 결혼한 날',
        style: textTheme.bodyLarge,
      ),
      const SizedBox(height: 16.0),
      Text(
        '${firstDay.year}.${firstDay.month}.${firstDay.day}',
        style: textTheme.bodyMedium,
      ),
      const SizedBox(height: 16.0),
      IconButton(
        iconSize: 60.0,
        onPressed: onHeartPressed,
        icon: const Icon(Icons.favorite, color: Colors.red),
      ),
      const SizedBox(height: 16.0),
      Text(
        'D+${DateTime(now.year, now.month, now.day).difference(firstDay).inDays + 1}',
        style: textTheme.displayMedium,
      ),
    ]);
  }
}

class _CoupleImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Image.asset('asset/img/middle_image.png',
            height: MediaQuery.of(context).size.height / 2),
      ),
    );
  }
}
