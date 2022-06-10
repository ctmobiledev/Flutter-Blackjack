// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:math';
import 'dart:async'; // for timer functions, Credit: https://stackoverflow.com/questions/14946012/how-do-i-run-a-reoccurring-function-in-dart

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

  Timer? timer;

  int bank = 1000;
  int wager = 0;
  int houseCount = 0;
  int playerCount = 0;
  int lastCard = 0;

  double statusCellWidth =
      120.0; // MUST RESTART APP TO SEE CHANGES; ONCE OUTER WIDGET RENDERED, DOES NOT CHANGE DYNAMICALLY
  double statusTableWidth = 0.0; // couldn't set value here; see the main() call

  bool buttonsDisabled = true; // a little backwards; should be "enabled" IMO
  var enabledButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(100, 50), primary: Colors.blue);
  var disabledButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(100, 50), primary: Colors.grey);

  StringBuffer sbGameState = StringBuffer("wager");

  // Game states: wager, deal, player, house, pay

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

  // SAMPLE METHOD/ROUTINE TO CHANGE VARIABLES - REQUIRES setState()
  /*
  void _incrementCounter() {
    setState(() {
      // Any actions to change any variables go inside setState() - a bit
      // superfluous for most programming platforms, but required here.
      // A call here triggers the build() method, which repaints widgets.
      //_counter++;
    });
  }
  */

  /*
  ALL THE ACTION TAKES PLACE IN THE SCAFFOLD INSIDE THE WIDGET.
  THE MAIN LAYOUT REALLY RESIDES HERE. IT SERVES AS THE FRAME OR STAGE
  FOR THE APP.
  */

  @override
  Widget build(BuildContext context) {
    statusTableWidth = (3 * statusCellWidth) + 2.0;
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          // The parent object has this.
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
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
                  margin: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                  child: const Text('Welcome to Flutter Blackjack!',
                      style: TextStyle(fontSize: 26.0)),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: const Text(
                    'Current Bankroll',
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    width: 250,
                    color: Colors.black,
                    padding: const EdgeInsets.only(bottom: 7.0),
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Text('\$$bank',
                        style: const TextStyle(
                            fontSize: 60.0, color: Colors.white))),
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: const Text(
                    'Type your wager below and press Enter:',
                  ),
                ),
                Container(
                  width: 200,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: txtWager,
                    onSubmitted: (value) {
                      setState(() {
                        print(">>> Value entered: $value");

                        // make sure a wager was entered
                        if (txtWager.text.trim() == "") {
                          showMessage("What, no wager?");
                          return;
                        }

                        // unlock buttons
                        buttonsDisabled = false;
                        print(">>> buttonsDisabled = " +
                            buttonsDisabled.toString());

                        wager = int.tryParse(value) ?? 0;
                        sbGameState = StringBuffer("deal");

                        playerCount = 0;
                        houseCount = 0;

                        dealCards();
                      });
                    },
                    style: TextStyle(fontSize: 30.0),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "",
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black)), // ADDS TO HEIGHT, WIDTH
                  alignment: Alignment.center,
                  width: statusTableWidth,
                  height: 132, // WARNING: COMPILER FLAGS OVERRUNS OF THE PARENT
                  margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                  child: Column(children: [
                    Row(children: [
                      Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          width: statusCellWidth,
                          height: 40.0,
                          child: Text(
                            "Player",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                      Container(
                          color: Colors.blue,
                          alignment: Alignment.center,
                          width: statusCellWidth,
                          height: 40.0,
                          child: Text(
                            "Last Card",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                      Container(
                          color: Colors.green,
                          alignment: Alignment.center,
                          width: statusCellWidth,
                          height: 40.0,
                          child: Text(
                            "House",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                    ]),
                    Row(children: [
                      Container(
                          alignment: Alignment.center,
                          width: statusCellWidth,
                          height: 70.0,
                          child: Text(playerCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 60.0))),
                      Container(
                          alignment: Alignment.center,
                          width: statusCellWidth,
                          height: 52.0,
                          child: Text(lastCard.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 48.0, color: Colors.blue))),
                      Container(
                          alignment: Alignment.center,
                          width: statusCellWidth,
                          height: 70.0,
                          child: Text(houseCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 60.0))),
                    ]),
                  ]),
                ),
                // https://stackoverflow.com/questions/49351648/how-do-i-disable-a-button-in-flutter
                Container(
                  margin: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  width: 220,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: buttonsDisabled
                            ? () {
                                // nop - change color?
                              }
                            : () {
                                playerHits();
                              },
                        style: buttonsDisabled
                            ? disabledButtonStyle
                            : enabledButtonStyle,
                        child: const Text('Hit'),
                      ),
                      ElevatedButton(
                        onPressed: buttonsDisabled
                            ? () {
                                // lock buttons
                                buttonsDisabled = true;
                                print(">>> buttonsDisabled = " +
                                    buttonsDisabled.toString());
                              }
                            : () {
                                housePlays();
                              },
                        style: buttonsDisabled
                            ? disabledButtonStyle
                            : enabledButtonStyle,
                        child: const Text('Stand'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // ACTION METHODS
  void dealCards() {
    print(">>> dealCards()");
    setState(() {
      var msNow = DateTime.now().millisecondsSinceEpoch;

      // NOTE: a seed is only needed the first call - was getting pairs of numbers and
      // the time presumably hadn't changed quickly enough

      int card = Random().nextInt(10) + 1;
      playerCount += card;
      print(">>> playerCount 1 = " + playerCount.toString());

      card = Random().nextInt(10) + 1;
      playerCount += card;
      print(">>> playerCount 2 = " + playerCount.toString());

      card = Random(msNow).nextInt(10) + 1;
      houseCount += card;
      print(">>> houseCount 1 = " + houseCount.toString());

      // HOUSE gets one card up
      //card = Random().nextInt(10) + 1;
      //houseCount += card;
      //print(">>> houseCount 2 = " + houseCount.toString());
    });
  }

  void playerHits() {
    setState(() {
      var msNow = DateTime.now().millisecondsSinceEpoch;
      int card = Random(msNow).nextInt(10) + 1;

      lastCard = card;
      playerCount += card;

      // Determine the outcome

      if (playerCount == 21) {
        playerWins(1.5);
        showMessage("21! You win 3:2 on your wager!\nYou now have \$$bank.");
      }

      if (playerCount > 21) {
        playerLoses();
        showMessage("Bust! You lose!\nYou now have \$$bank.");
      }
    });
  }

  void housePlays() {
    setState(() {
      buttonsDisabled = true;
      timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        houseHits();
      });
    });
  }

  void houseHits() {
    setState(() {
      var msNow = DateTime.now().millisecondsSinceEpoch;
      int card = Random(msNow).nextInt(10) + 1;

      if (houseCount < 17) {
        lastCard = card;
        houseCount += card;

        if (houseCount >= 17) {
          if (houseCount > 21) {
            // automatic win, house busts
            timer?.cancel();
            playerWins(1.0); // regular odds, even money
            showMessage("You win! House busts!\nYou now have \$$bank.");
          } else {
            compareHands();
          }
        }
      } else {
        compareHands(); // house is at 17+ already, do it right now
      }

      // House must take cards until 17 or over
    });
  }

  void compareHands() {
    timer?.cancel();
    if (houseCount > playerCount) {
      playerLoses();
      showMessage(
          "House wins! House $houseCount beats your $playerCount.\nYou now have \$$bank.");
    } else if (playerCount > houseCount) {
      playerWins(1.0); // regular odds, even money
      showMessage(
          "You win! Your $playerCount beats House's $houseCount.\nYou now have \$$bank.");
    } else {
      // it's a push - no win, no loss
      playerWins(0); // resets game state anyway
      showMessage("It's a push! Counts are equal.\nYou still have \$$bank.");
    }
  }

  void showMessage(String msgText) {
    timer?.cancel();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Flutter Blackjack'),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              resetGameState();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void playerLoses() {
    setState(() {
      bank = bank - wager;
      print(">>> playerLoses() - bank = " + bank.toString());
      // a redraw is automatically triggered since setState() is fired

      sbGameState = StringBuffer("wager");
    });
  }

  void playerWins(double dblMultiplier) {
    setState(() {
      bank = (bank.toDouble() + (dblMultiplier * wager.toDouble())).toInt();
      print(">>> playerLoses() - bank = " + bank.toString());
      // a redraw is automatically triggered since setState() is fired

      sbGameState = StringBuffer("wager");
    });
  }

  void resetGameState() {
    setState(() {
      playerCount = 0;
      houseCount = 0;
      lastCard = 0;

      wager = 0;
      txtWager.text = "";

      // re-lock buttons
      buttonsDisabled = true;
      print(">>> resetGameState - buttonsDisabled = " +
          buttonsDisabled.toString());
    });
  }
}
