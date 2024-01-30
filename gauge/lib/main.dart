import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'variable.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data directly when the widget is created
  }

  fetchData() async {
    print('Fetching users...');
    const url = 'http://13.127.214.1:3000/api/v1/vid_12347/vehicledata';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        DataHolder.users = json['data'];
      });
      print('Users fetched successfully');
    } else {
      print('Failed to fetch users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        appBar: AppBar(title: Text('KDGaugeView Example')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircularArcWithAvatar(),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularArcWithAvatar extends StatelessWidget {
  @override
  // final int data1 = 70; //////text cahnge variable

  Widget build(BuildContext context) {
    // DataHolder.updateBatteryValue();
    DataHolder.batteryValue = int.tryParse(DataHolder.users.isNotEmpty
            ? DataHolder.users[0]['BatteryVoltage'].toString()
            : '') ??
        0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Circular_arc(),
        Positioned(
          bottom: 160, // Adjust the bottom position as needed
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Color.fromARGB(255, 255, 238, 5),
            child: Text(
              '${DataHolder.batteryValue.toStringAsFixed(0)}', /////////////////////it is changed from decimal to string
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}

class Circular_arc extends StatefulWidget {
  const Circular_arc({Key? key}) : super(key: key);

  @override
  _Circular_arcState createState() => _Circular_arcState();
}

class _Circular_arcState extends State<Circular_arc>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animController;
  //final data = 70; //////////////////////////gauge change variable
  double calculation = 0.0;
  double beginvalue =
      0.0; ////////////////////////////////////////////we can control the start and end value by this
  double endvalue = 0.0; //////////////////////////////////////////////
  @override
  void initState() {
    super.initState();

    calculation = DataHolder.data / 100;
    beginvalue = 0.0;
    endvalue = 4.6 * calculation;

    animController =
        AnimationController(duration: Duration(seconds: 2), vsync: this);

    final curvedAnimation =
        CurvedAnimation(parent: animController, curve: Curves.easeInOutCubic);

    animation =
        Tween<double>(begin: beginvalue, end: endvalue).animate(curvedAnimation)
          ..addListener(() {
            setState(() {});
          });

    // Use forward to play the animation once
    animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        size: Size(300, 300),
        painter: ProgressArc(animation.value, Color(0xFFFF0000), true),
      ),
    );
  }

  @override
  void dispose() {
    animController.dispose(); // Dispose the animation controller
    super.dispose();
  }
}

class ProgressArc extends CustomPainter {
  bool isBackground;
  double arc;
  Color progressColor;

  ProgressArc(this.arc, this.progressColor, this.isBackground);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 30.0;
    //final data = 70; //////////////////////////////////color change variable
    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), radius: 30);
    final startAngle = math.pi * 2.77;
    final sweepAngle = arc != null ? arc : math.pi;
    final useCenter = false;

    // Draw filled background circle
    if (isBackground) {
      final borderColor =
          Color.fromARGB(255, 235, 235, 235); // Set your desired border color

      final backgroundPaint = Paint()
        ..color = Color.fromARGB(255, 77, 77, 77)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;

      final startAngleBackground = math.pi * 0.94 - (math.pi / 6);

      ///adjustment for the start angle
      final sweepAngleBackground =
          math.pi * 1.46; //adjustment for the end angle

      // Draw the background arc with border
      canvas.drawArc(rect, startAngleBackground, sweepAngleBackground,
          useCenter, backgroundPaint);
      canvas.drawArc(
        rect,
        startAngleBackground,
        sweepAngleBackground,
        useCenter,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5,
      );
    }
    Color arcColor = (DataHolder.data > 20 && DataHolder.data < 90)
        ? Colors.green
        : Colors.red;
    //color changing when 90 or 20
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
