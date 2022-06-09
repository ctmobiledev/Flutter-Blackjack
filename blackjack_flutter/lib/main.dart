// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

void main() {
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Blackjack'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // "State" is essentially the "universe" of all variables and objects.

  int bank = 1000;
  int wager = 0;
  int houseCount = 0;
  int playerCount = 0;

  int newCardRank = 0; // value from 1 to 10

  // One of these is needed for each text field, and the dispose() method
  // is needed to do cleanup per each object.
  final txtWager = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    txtWager.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // Any actions to change any variables go inside setState() - a bit
      // superfluous for most programming platforms, but required here.
      // A call here triggers the build() method, which repaints widgets.
      //_counter++;
    });
  }

  /*
  ALL THE ACTION TAKES PLACE IN THE SCAFFOLD INSIDE THE WIDGET.
  THE MAIN LAYOUT REALLY RESIDES HERE. IT SERVES AS THE FRAME OR STAGE
  FOR THE APP.
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // The parent object has this.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // a list of widgets
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              child: const Text(
                'Welcome to Flutter Blackjack!',
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 0.0),
              child: const Text(
                'You currently have a bank of',
              ),
            ),
            Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                child: Text('\$$bank', style: const TextStyle(fontSize: 30.0))),
            Container(
              margin: const EdgeInsets.only(bottom: 5.0),
              child: const Text(
                'Enter your wager below',
              ),
            ),
            Container(
              width: 200,
              height: 60,
              margin: const EdgeInsets.only(bottom: 10.0),
              child: TextField(
                controller: txtWager,
                onSubmitted: (value) {
                  setState(() {
                    print(">>> Value entered: $value");
                    wager = int.tryParse(value) ?? 0;
                  });
                },
                style: TextStyle(fontSize: 30.0),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.black)), // ADDS TO HEIGHT, WIDTH
              alignment: Alignment.center,
              width: 302,
              height: 132, // WARNING: COMPILER FLAGS OVERRUNS OF THE PARENT
              margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: Column(children: [
                Row(children: [
                  Container(
                      color: Colors.green,
                      alignment: Alignment.center,
                      width: 150.0,
                      height: 40.0,
                      child: Text("Player", textAlign: TextAlign.center)),
                  Container(
                      color: Colors.green,
                      alignment: Alignment.center,
                      width: 150.0,
                      height: 40.0,
                      child: Text("House", textAlign: TextAlign.center)),
                ]),
                Row(children: [
                  Container(
                      alignment: Alignment.center,
                      width: 150.0,
                      height: 70.0,
                      child: Text("0",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 60.0))),
                  Container(
                      alignment: Alignment.center,
                      width: 150.0,
                      height: 70.0,
                      child: Text("0",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 60.0))),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
