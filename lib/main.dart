// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vtask/todo-list.dart';

GlobalKey<ToDoListState> toDoListKey = GlobalKey();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'VTask';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        home: MyStatefulWidget(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: Color.fromARGB(255, 43, 44, 58),
          accentColor: Color.fromARGB(255, 146, 149, 231),
          errorColor: Color.fromARGB(255, 193, 136, 134),
          bottomAppBarColor: Colors.white10,
          scaffoldBackgroundColor: Color.fromARGB(255, 43, 44, 58),

          // Define the default font family.
          fontFamily: 'Roboto',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w300),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ));
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  ToDoListController toDoListController = ToDoListController();
  bool _isSelectMode = false;
  bool _hasSelected = false;
  BannerAd? myBanner;
  AdWidget? adWidget;
  AdSize? adSize;

  void _handleIsSelectModeChange(bool newValue) {
    setState(() {
      _isSelectMode = newValue;
    });
    if (_isSelectMode == false) {
      _handlehasSelectedChange(false);
    }
  }

  void _handlehasSelectedChange(bool newValue) {
    setState(() {
      _hasSelected = newValue;
    });
  }

  void confirmDelete() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Delete"),
            titlePadding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
            contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Text(
                    "Would you like to remove the selected item(s)?",
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: TextButton(
                        child: Text("cancel",
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: TextButton(
                        child: Text("confirm",
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        onPressed: () {
                          toDoListController.deleteSelectedItems();
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<bool> _onWillPop() {
    bool result = false;
    if (_isSelectMode) {
      setState(() {
        _isSelectMode = false;
        _hasSelected = false;
      });
    } else {
      result = true;
    }
    return Future.value(result);
  }

  final AdListener customAdListener = AdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an ad is in the process of leaving the application.
    onApplicationExit: (Ad ad) => print('Left application.'),
  );

  AdWidget _getAdWidget(BuildContext context) {
    final contextSize = MediaQuery.of(context).size;
    final AdSize adSize = AdSize(width: contextSize.width.toInt(), height: 70);
    // Load ads.
    myBanner = BannerAd(
      adUnitId: 'ca-app-pub-6163366343175647/8879307154',
      size: adSize,
      request: AdRequest(),
      listener: customAdListener,
    );

    adWidget = AdWidget(ad: myBanner as BannerAd);
    (myBanner as BannerAd).load();
    return adWidget as AdWidget;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text('VTask'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                  iconSize: 30.0,
                  color: Theme.of(context).accentColor,
                  disabledColor: Colors.white.withOpacity(.3),
                  tooltip: 'More Options',
                  icon: !_isSelectMode
                      ? const Icon(Icons.keyboard_arrow_down)
                      : const Icon(Icons.keyboard_arrow_up_rounded),
                  onPressed: !_isSelectMode
                      ? () {
                          toDoListController.startSelect();
                        }
                      : () {
                          toDoListController.cancelSelect();
                        }),
            ),
          ],
          backgroundColor: Theme.of(context).primaryColor,
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).primaryColor,
              // statusBarColor: Theme.of(context).primaryColor,
              statusBarIconBrightness: Brightness.light),
          bottom: !_isSelectMode
              ? null
              : PreferredSize(
                  preferredSize: !_isSelectMode
                      ? Size.fromHeight(0.0)
                      : Size.fromHeight(70.0),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      children: <Widget>[
                        TextButton(
                          autofocus: false,
                          onPressed: !_isSelectMode
                              ? null
                              : () {
                                  toDoListController.toggleAllItems();
                                },
                          child: Container(
                            margin: EdgeInsets.only(left: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    Icons.select_all_outlined,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text("Toggle All",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                              color: _hasSelected
                                  ? Theme.of(context).errorColor
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(8)),
                          child: IconButton(
                              iconSize: 30.0,
                              color: _hasSelected
                                  ? Colors.white
                                  : Theme.of(context).errorColor.withAlpha(200),
                              disabledColor: Colors.white.withOpacity(.3),
                              tooltip: 'Delete Item(s)',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: !_isSelectMode || !_hasSelected
                                  ? null
                                  : confirmDelete),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 6,
          elevation: 0,
          // color: Colors.grey[900],
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 120,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Spacer(),
                      IconButton(
                          iconSize: 30.0,
                          color: Theme.of(context).accentColor,
                          disabledColor: Colors.grey.withOpacity(.3),
                          tooltip: 'Undo',
                          icon: const Icon(Icons.undo_outlined),
                          onPressed: !_isSelectMode ? null : null),
                      Spacer(),
                      IconButton(
                          iconSize: 30.0,
                          color: Colors.amber[900],
                          disabledColor: Colors.grey.withOpacity(.3),
                          tooltip: 'Redo',
                          icon: const Icon(Icons.redo_outlined),
                          onPressed: !_isSelectMode ? null : null),
                      Spacer(),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: _getAdWidget(context),
                  width: myBanner is BannerAd
                      ? (myBanner as BannerAd).size.width.toDouble()
                      : null,
                  height: myBanner is BannerAd
                      ? (myBanner as BannerAd).size.height.toDouble()
                      : null,
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).accentColor.withAlpha(250),
            onPressed: () {
              toDoListController.addItem();
            },
            tooltip: 'Add Item',
            child: const Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Column(
          children: [
            Expanded(
              child: ToDoList(
                  controller: toDoListController,
                  key: toDoListKey,
                  isSelectMode: _isSelectMode,
                  onSelectModeChange: _handleIsSelectModeChange,
                  onSelectedItemsChange: _handlehasSelectedChange),
            )
          ],
        ),
      ),
    );
  }
}
