import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double x = 0;
  double y = 0;
  double z = 0;

  late Animation<double> rot;
  late Animation<double> left;

  bool enabledSensor = true;

  late Animation<Color?> color;

  @override
  void initState() {
    super.initState();
    gyroscopeEvents
        // .throttleTime(const Duration(milliseconds: 16))
        .listen((event) {
      if (!enabledSensor) {
        return;
      }
      print('on subsscribe');
      setState(() {
        x += event.x;
        y += event.y;
        z += event.z;
      });
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    rot = Tween<double>(begin: 0, end: pi).animate(_controller);
    left = Tween<double>(begin: 0, end: -50).animate(_controller);
    color =
        ColorTween(begin: Colors.grey, end: Colors.green).animate(_controller);

    // _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: <Widget>[
        Positioned(
            right: 50,
            top: 20,
            child: Text('x: ${(x * 200).toStringAsFixed(5)}')),
        Positioned(
            right: 50,
            top: 40,
            child: Text('y: ${(y * 200).toStringAsFixed(5)}')),
        Positioned(
            right: 50,
            top: 60,
            child: Text('z: ${(z * 200).toStringAsFixed(5)}')),
        Positioned(
          right: 50,
          top: 100,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                x = 0;
                y = 0;
                z = 0;
              });
            },
            child: const Text('reset'),
          ),
        ),
        AnimatedPositioned(
            width: 50,
            height: 50,
            left: (max(
                0,
                min(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.width - 50 + (y * 200)) /
                    2)),
            top: (max(
                0,
                min(MediaQuery.of(context).size.height,
                        MediaQuery.of(context).size.height - 50 + (x * 200)) /
                    2)),
            duration: const Duration(milliseconds: 16),
            child: AnimatedContainer(
              color: Theme.of(context).primaryColor,
              duration: const Duration(milliseconds: 500),
            )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (enabledSensor) {
            _controller.forward();
          } else {
            _controller.reverse();
          }

          setState(() => enabledSensor = !enabledSensor);
        },
        tooltip: 'Increment',
        label: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Row(
              children: [
                Transform(
                  transform: Matrix4.translationValues(
                      -left.value, -sin(rot.value) * 20, 0),
                  child: const Icon(Icons.play_arrow),
                ),
                const Icon(Icons.arrow_right_alt),
                Transform(
                  transform: Matrix4.translationValues(
                      left.value, sin(rot.value) * 20, 0),
                  child: const Icon(Icons.stop),
                ),
              ],
            );
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
