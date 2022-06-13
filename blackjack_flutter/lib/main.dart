/*
******************************************************************************

FLUTTER BLACKJACK
A demo of basic Dart and Flutter concepts

Author: Charles Tatum II
Original Creation Date: June 2022

******************************************************************************
*/

// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:math';
import 'dart:async'; // for timer functions, Credit: https://stackoverflow.com/questions/14946012/how-do-i-run-a-reoccurring-function-in-dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for screen orientation lock

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // No landscape
  // Credit: https://www.flutterbeads.com/change-lock-device-orientation-portrait-landscape-flutter/
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

/*
**********************************************************************************
HOME SCREEN
**********************************************************************************
*/

const Color themeColor =
    Color.fromRGBO(23, 130, 212, 1); // = 0xFF1782d4, set separately below
const Map<int, Color> themeColorMap = {
  // all these values required for definition.
  // I don't need shades of the color so I've defaulted them all to a single constant
  50: themeColor,
  100: themeColor,
  200: themeColor,
  300: themeColor,
  400: themeColor,
  500: themeColor,
  600: themeColor,
  700: themeColor,
  800: themeColor,
  900: themeColor,
};
MaterialColor? themeColorMaterial = MaterialColor(0xFF1782d4, themeColorMap);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        primarySwatch: themeColorMaterial,
      ),
      home: const MyHomePage(title: 'Flutter Blackjack'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // "State" is essentially the "universe" of all variables and objects.

  Timer? timer;

  List<String> cardRanks = [
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    'J',
    'Q',
    'K',
    'A'
  ];
  List<int> cardValues = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 1];

  int bank = 1000;
  int wager = 0;
  int houseCount = 0;
  int playerCount = 0;
  int lastCard = 0;
  StringBuffer sbLastCard = StringBuffer("");

  double statusCellWidth =
      120.0; // MUST RESTART APP TO SEE CHANGES; ONCE OUTER WIDGET RENDERED, DOES NOT CHANGE DYNAMICALLY
  double statusTableWidth = 0.0; // couldn't set value here; see the main() call

  bool hitStandButtonsDisabled =
      true; // a little backwards; should be "enabled" IMO
  var enabledButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(100, 50), primary: themeColor);
  var disabledButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(100, 50), primary: Colors.grey);

  bool wagerButtonDisabled =
      false; // a little backwards; should be "enabled" IMO
  var enabledWagerButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(120, 70), primary: themeColor);
  var disabledWagerButtonStyle = ElevatedButton.styleFrom(
      fixedSize: const Size(120, 70), primary: Colors.grey);

  var aboutButtonStyle = ElevatedButton.styleFrom(primary: Colors.black);

  bool messageVisible = true; // a little backwards; should be "enabled" IMO

  StringBuffer sbGameState = StringBuffer("wager");
  StringBuffer sbMessage = StringBuffer(
      "Welcome to the casino!\nEnter your wager in the blue box above and press the Wager button.");
  String strNextWagerMsg = "\nPlace your next wager.";

  // Game states: wager, deal, player, house, pay

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

  /*
  ALL THE ACTION TAKES PLACE IN THE SCAFFOLD INSIDE THE WIDGET.
  THE MAIN LAYOUT REALLY RESIDES HERE. IT SERVES AS THE FRAME OR STAGE
  FOR THE APP.
  */

  @override
  Widget build(BuildContext context) {
    statusTableWidth = (3 * statusCellWidth) + 2.0;

    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
              width: 300.0,
              height: 50.0,
              margin: const EdgeInsets.only(
                  left: 100.0, right: 100.0, bottom: 18.0),
              child: ElevatedButton(
                  style: aboutButtonStyle,
                  onPressed: () {
                    // AlertDialog or second window
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutPageRoute()),
                    );
                  },
                  child: const Text('About This App'))),
        ),
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // a list of widgets
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: const Text(
                  'Current Bankroll',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      width: 250,
                      height: 70,
                      color: Colors.black,
                      padding: const EdgeInsets.only(top: 15.0, bottom: 0.0),
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: Text('\$$bank',
                          style: const TextStyle(
                              fontSize: 60.0,
                              fontFamily: 'GasPumpLCD',
                              color: Colors.orange))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 70,
                    decoration: BoxDecoration(
                        border: Border.all(color: themeColor, width: 3.0)),
                    padding: const EdgeInsets.only(top: 5.0),
                    margin: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, right: 10.0),
                    child: TextField(
                      // Credit: https://www.flutterbeads.com/numeric-input-keyboard-in-flutter/
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      controller: txtWager,
                      enabled: !wagerButtonDisabled,
                      // No bottom underline in TextField
                      // Credit: https://stackoverflow.com/questions/49040679/flutter-how-to-make-a-textfield-with-hinttext-but-no-underline
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none),
                      onSubmitted: (String value) {
                        // for Android, Windows, other non-iOS users who can tap Done or Enter
                        // iOS users MUST use the Wager button, they have no choice (poor dears)
                        if (value.trim() == "") {
                          showAlertDialog("What, no wager?");
                          return;
                        } else {
                          closeNumpad();
                          recordWager(value);
                        }
                      },
                      style: TextStyle(
                          fontSize: 52.0,
                          fontFamily: 'GasPumpLCD',
                          color:
                              (wagerButtonDisabled ? Colors.grey : themeColor)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: wagerButtonDisabled
                        ? () {
                            // nop when button tapped
                          }
                        : () {
                            // logic for Enter pressed including closing of numpad
                            // make sure a wager was entered
                            if (txtWager.text.trim() == "") {
                              showAlertDialog("What, no wager?");
                              return;
                            } else {
                              closeNumpad();
                              recordWager(txtWager.text);
                            }
                          },
                    style: wagerButtonDisabled
                        ? disabledWagerButtonStyle
                        : enabledWagerButtonStyle,
                    child: const Text(
                      'Wager',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black)), // ADDS TO HEIGHT, WIDTH
                alignment: Alignment.center,
                height: 114, // WARNING: COMPILER FLAGS OVERRUNS OF THE PARENT
                margin: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Container(
                          color: Colors.orange,
                          alignment: Alignment.center,
                          height: 40.0,
                          child: Text(
                            "Player",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    Expanded(
                      child: Container(
                          color: themeColor,
                          alignment: Alignment.center,
                          height: 40.0,
                          child: Text(
                            "Last Card",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    Expanded(
                      child: Container(
                          color: Colors.orange,
                          alignment: Alignment.center,
                          height: 40.0,
                          child: Text(
                            "House",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          height: 70.0,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(playerCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 60.0,
                                  fontFamily: 'GasPumpLCD',
                                  color: Colors.black))),
                    ),
                    Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          height: 44.0,
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Text(sbLastCard.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor))),
                    ),
                    Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          height: 70.0,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(houseCount.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 60.0,
                                  fontFamily: 'GasPumpLCD',
                                  color: Colors.black))),
                    ),
                  ]),
                ]),
              ),
              // https://stackoverflow.com/questions/49351648/how-do-i-disable-a-button-in-flutter
              Container(
                margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                width: 220,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: hitStandButtonsDisabled
                          ? () {
                              // nop when button tapped
                            }
                          : () {
                              playerHits();
                            },
                      style: hitStandButtonsDisabled
                          ? disabledButtonStyle
                          : enabledButtonStyle,
                      child: const Text(
                        'Hit',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: hitStandButtonsDisabled
                          ? () {
                              // lock buttons
                              hitStandButtonsDisabled = true;
                              print(">>> buttonsDisabled = " +
                                  hitStandButtonsDisabled.toString());
                            }
                          : () {
                              housePlays();
                            },
                      style: hitStandButtonsDisabled
                          ? disabledButtonStyle
                          : enabledButtonStyle,
                      child: const Text(
                        'Stand',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                  visible: messageVisible,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          sbMessage.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        )));
  }

  //***********************************************
  // ACTION METHODS
  //***********************************************

  void closeNumpad() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void recordWager(String value) {
    setState(() {
      print(">>> Value entered: $value");

      // switch off the message
      messageVisible = false;

      wager = int.tryParse(value) ?? 0;

      if (wager > bank) {
        showAlertDialog("Nice try. You don't have that much money!");
        return;
      }

      // lock the wager button
      wagerButtonDisabled = true;

      // clear the last card
      lastCard = 0;
      sbLastCard.clear();

      // unlock hit and stand buttons
      hitStandButtonsDisabled = false;
      print(">>> hitStandButtonsDisabled = " +
          hitStandButtonsDisabled.toString());

      sbGameState = StringBuffer("deal");

      playerCount = 0;
      houseCount = 0;

      dealCards();
    });
  }

  void resetCardCounts() {
    setState(() {
      txtWager.text = "";
      hitStandButtonsDisabled = true;
    });
  }

  void resetForNextRound() {
    setState(() {
      txtWager.text = "";
      hitStandButtonsDisabled = true;
    });
  }

  void dealCards() {
    print(">>> dealCards()");
    setState(() {
      var msNow = DateTime.now().millisecondsSinceEpoch;

      // NOTE: a seed is only needed the first call - was getting pairs of numbers and
      // the time presumably hadn't changed quickly enough

      int card = Random(msNow).nextInt(13);
      playerCount += cardValues[card];
      print(">>> playerCount 1 = " + playerCount.toString());

      card = Random().nextInt(13);
      playerCount += cardValues[card];
      print(">>> playerCount 2 = " + playerCount.toString());

      card = Random().nextInt(13);
      houseCount += cardValues[card];
      if (houseCount == 1) {
        houseCount = 11; // assume an Ace is showing at this point
      }
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
      int card = Random(msNow).nextInt(13);

      // work the Ace magic here
      lastCard = cardValues[card];
      sbLastCard = StringBuffer(cardRanks[card]);

      if (lastCard != 1) {
        playerCount += cardValues[card];
      } else {
        // could be a 1 or 11
        if (playerCount < 11) {
          playerCount += 11;
        } else {
          playerCount += 1;
        }
      }

      // Determine the outcome

      if (playerCount == 21) {
        playerWins(1.5);
        showMessage("21! You win 3:2 on your wager!\nYou now have \$$bank." +
            placeNextWagerMsg(bank));
        resetForNextRound();
      }

      if (playerCount > 21) {
        playerLoses();
        showMessage(
            "Bust! You lose!\nYou now have \$$bank." + placeNextWagerMsg(bank));
        resetForNextRound();
      }
    });
  }

  void housePlays() {
    setState(() {
      hitStandButtonsDisabled = true;
      timer = Timer.periodic(Duration(milliseconds: 750), (timer) {
        houseHits();
      });
    });
  }

  void houseHits() {
    setState(() {
      var msNow = DateTime.now().millisecondsSinceEpoch;
      int card = Random(msNow).nextInt(13);

      // No Ace magic for house?
      if (houseCount < 17) {
        lastCard = cardValues[card];
        sbLastCard = StringBuffer(cardRanks[card]);
        houseCount += cardValues[card];

        if (houseCount >= 17) {
          if (houseCount > 21) {
            // automatic win, house busts
            timer?.cancel();
            playerWins(1.0); // regular odds, even money
            showMessage("You win! House busts!\nYou now have \$$bank." +
                placeNextWagerMsg(bank));
            resetForNextRound();
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
          "House wins! House $houseCount beats your $playerCount.\nYou now have \$$bank." +
              placeNextWagerMsg(bank));
    } else if (playerCount > houseCount) {
      playerWins(1.0); // regular odds, even money
      showMessage(
          "You win! Your $playerCount beats House's $houseCount.\nYou now have \$$bank." +
              placeNextWagerMsg(bank));
    } else {
      // it's a push - no win, no loss
      playerWins(0); // resets game state anyway
      showMessage("It's a push! Counts are equal.\nYou still have \$$bank." +
          placeNextWagerMsg(bank));
    }
    resetForNextRound();
  }

  void showAlertDialog(String msgText) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Flutter Blackjack'),
        content: Text(msgText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showMessage(String msgText) {
    timer?.cancel();

    setState(() {
      messageVisible = true;
      sbMessage = StringBuffer(msgText);
    });
  }

  void playerLoses() {
    setState(() {
      bank = bank - wager;
      print(">>> playerLoses() - bank = " + bank.toString());
      // a redraw is automatically triggered since setState() is fired

      if (bank > 0) {
        wagerButtonDisabled = false;
      } else {
        wagerButtonDisabled = true; // no more betting
      }

      sbGameState = StringBuffer("wager");
    });
  }

  void playerWins(double dblMultiplier) {
    setState(() {
      bank = (bank.toDouble() + (dblMultiplier * wager.toDouble())).toInt();
      print(">>> playerWins() - bank = " + bank.toString());
      // a redraw is automatically triggered since setState() is fired

      wagerButtonDisabled = false;

      sbGameState = StringBuffer("wager");
    });
  }

  void resetForNextHand() {
    setState(() {
      playerCount = 0;
      houseCount = 0;
      lastCard = 0;
      sbLastCard.clear();

      wager = 0;
      txtWager.text = "";

      // re-lock buttons
      hitStandButtonsDisabled = true;
      print(">>> resetGameState - buttonsDisabled = " +
          hitStandButtonsDisabled.toString());
    });
  }

  String placeNextWagerMsg(int lastBank) {
    String? outMsg;

    if (lastBank <= 0) {
      outMsg =
          "\nYou are officially BROKE!\nFor more funds, just restart the game!";
    } else {
      outMsg = "\nPlace your next wager.";
    }

    return outMsg;
  }
}

/*
**********************************************************************************
ABOUT SCREEN
**********************************************************************************
*/

// NOTE: This widget is external to the main one above, and thus cannot see the
// objects defined inside of it.

class AboutPageRoute extends StatelessWidget {
  const AboutPageRoute({super.key});

  @override
  Widget build(BuildContext context) {
    var closeButtonStyle = ElevatedButton.styleFrom(
        primary: Colors.black, fixedSize: Size(180.0, 50.0));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About This App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          margin:
              EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Credit: https://flutteragency.com/singlechildscrollview-widget/
            // This allows for a block of text as long as desired, with vertical scrolling
            // that adjusts properly for any vertical screen size.
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(
                      child: Text(
                        'Author: Charles Tatum II'
                        '\n\n'
                        'This app is the first app I used to learn how to '
                        'write for Flutter using Dart.  The Blackjack game '
                        'represented is a simplified version, so there\'s no splitting '
                        'of hands, no insurance bets, or any of the fancy stuff. '
                        'This also presumes an infinite "shoe" of multiple decks of cards '
                        'so forget about card counting.'
                        '\n\n'
                        'This project turned out to be a decent working model of a number of '
                        'different Flutter and Dart concepts including detection of '
                        'button press events, styling of controls, and (perhaps especially) '
                        'how Flutter manages layout formatting.'
                        '\n',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: closeButtonStyle,
                onPressed: () {
                  // Navigate back to first route when tapped.
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
