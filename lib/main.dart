
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi/wifi.dart';
import 'package:url_launcher/url_launcher.dart';


Connectivity _connectivity;
StreamSubscription<ConnectivityResult> _subscription;

void main() => runApp(MaterialApp(title: 'AutoConnect', home: MainActivity(), debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      '/SetPasswordPage' : (BuildContext context) => new SetPasswordPage(),
      '/UsePasswordPage' : (BuildContext context) => new UsePasswordPage(),
      '/SavedPasswordPage' : (BuildContext context) => new SavedPasswordPage(),

    }));

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}



class _MainActivityState extends State {

  bool connectionStatus = true;
  String WIFI_SSID = "WIN-BFFP4MARMKN 5784";
  //String ssid2 = "AndroidWifi";
  //String ssid3 = "421 Nelson";
  //String WIFI_SSID = "421 Nelson";
  //T;77666d

  //String msg2 = "";
  //String pass = "a";

  //String nextMonthPass = "T;77666d";
  bool statusAC = false;

  String wifiPass = "";
  String wifiPass2 = "";
  String msg = 'Autoconnect: OFF';
  String pass = 'admin';
  String serverResponse = 'pending...'; //password for the wifi from server
  String nextServerResponse = 'pending...';
  String url1 = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/?id=1';
  String url2 = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/?id=2';
  Dio dio = new Dio();



  _MainActivityState() {
    _connectivity = new Connectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(onConnectivityChange);
  }


  Future<String> createAlertDialog(BuildContext context){

    TextEditingController customController = TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('Enter Password'),
        content: TextField(
          controller: customController,
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text('Enter'),
            onPressed: (){
              if (customController.text.toString() == pass){
                //Navigator.of(context).pop;
                Navigator.of(context).pop(customController.text.toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RouterPage()),
                );
              }
              else
                print('this');
            },
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //backgroundColor: Colors.blue,
      appBar: AppBar(
          title: Text('AutoConnect'),
          backgroundColor: Colors.blueGrey[400]
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/BackgroundSupesLight.png'),
                fit: BoxFit.cover
            )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                margin: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(msg,
                  style: TextStyle(
                    fontSize: 25,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              /*
              Text(
                msg,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),

               */



              Container(
                width: 260,
                height: 220,
                child: FloatingActionButton(
                    child: Icon(
                      Icons.power_settings_new,
                      color: Colors.black,
                      size: 160,
                    ),
                    backgroundColor: connectionStatus?Colors.white:Colors.green,

                  onPressed: (){
                    _makeGetRequest('1');
                    _makeGetRequest('2');
                    setState(() {
                      if (msg == 'Autoconnect: ON') {
                        connectionStatus = true;
                        msg = 'Autoconnect: OFF';
                        serverResponse = 'pending...';
                        nextServerResponse = 'pending...';

                        print(serverResponse);
                        print(nextServerResponse);
                      }
                      else if (msg == 'Autoconnect: OFF') {
                        connectionStatus = false;
                        msg = 'Autoconnect: ON';
                        serverResponse = wifiPass;
                        nextServerResponse = wifiPass2;

                        print(serverResponse);
                        print(nextServerResponse);
                        connectingTest();
                      }
                    });
                  },
                ),
              ),

              // old code can be deleted
              /*
              RaisedButton(
                child: Text('AutoConnect'),
                onPressed: (){
                  _makeGetRequest('1');
                  _makeGetRequest('2');
                  setState(() {
                    if (msg == 'Autoconnect: ON') {
                      msg = 'Autoconnect: OFF';
                      serverResponse = 'pending...';
                      nextServerResponse = 'pending...';

                      print(serverResponse);
                      print(nextServerResponse);
                    }
                    else if (msg == 'Autoconnect: OFF') {
                      msg = 'Autoconnect: ON';
                      serverResponse = wifiPass;
                      nextServerResponse = wifiPass2;

                      print(serverResponse);
                      print(nextServerResponse);
                      connectingTest();
                    }
                  });
                },
                color: Colors.blue,
                textColor: Colors.black,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
              */

              RaisedButton(
                  child: Text('idk'),
                  onPressed: (){
                    _launchURL();
                    //checkPassStatus();
                  }
              ),
              //Server response text
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  //child: Text(status),
                  child: Text('Password: ' + serverResponse,
                    style: TextStyle(
                      fontSize: 18,
                    ),

                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  //child: Text(status),
                  child: Text('Next Password: ' + nextServerResponse,
                    style: TextStyle(
                      fontSize: 18,
                    ),

                  ),
                ),
              ),

              // old code can be deleted
              /*
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text(status),
                child: Text('Password: ' + serverResponse),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text(status),
                child: Text('Next Password: ' + nextServerResponse),
              ),

               */

              Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                    child: Text('Admin'),
                    color: Colors.blueGrey[300],
                    onPressed: () {
                      createAlertDialog(context);
                    },
                    textColor: Colors.black,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    splashColor: Colors.grey,
                  )

              ),

              // old code can be deleted
              /*
              RaisedButton(
                child: Text('Admin'),
                color: Colors.blueGrey[300],
                onPressed: () {
                  createAlertDialog(context);
                },
                textColor: Colors.black,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                //splashColor: Colors.grey,
              ),
              */
            ],
          ),
        ),

      ),
    );
  }

//  other() {
//    setState(() {
//   msg = 'AutoConnecting...';
//    });
//  }
//
  void onConnectivityChange(ConnectivityResult result) {

    print("CONNECTION STATE CHANGED"+ serverResponse + nextServerResponse);
    if(msg == 'Autoconnect: ON') {
      _checkInternetConnectivity();
    }


  }

  connectingTest() {
    WiFiForIoTPlugin.connect(
      WIFI_SSID,
      //password: serverResponse,
      password: "T;77666d",
      security: NetworkSecurity.WPA,
    );
  }

  checkPassStatus()async{


    var result = await Wifi.connection(WIFI_SSID, "T;77666d");

    if (result == WifiState.success || result == WifiState.already)
    {
      print("CONNECTION SUCCESS");
      print(result);
    }
    else if(result == WifiState.error)
    {
      print("ERROR CONNECTING");
    }
    //List<WifiResult> list = await Wifi.list('key'); // this key is used to filter
    //print(list);


  }


  _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      _showDialog(

          'No internet',
//          "You're not connected to a network"
          "Attemping to connect to Wi-fi"
      );
      connectingTest();
    } else if (result == ConnectivityResult.mobile) {
      _showDialog(
//          'Internet access',
//          "You're connected over mobile data"
          'No Wi-Fi (mobile data available)',
          "Attemping to connect to Wi-fi"
      );
      connectingTest();
    } else if (result == ConnectivityResult.wifi) {
      _showDialog(
          'Internet access',
          "You're connected over wifi"
      );
    }
  }

  _launchURL() async {
    const url = 'https://www.google.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _showDialog(title, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }






  _makeGetRequest(var i) async {
    Response getResponse;
    Response getResponse2;
    if(i == '1'){
      getResponse = await dio.get(url1);
      Map passMap = json.decode(getResponse.toString());
      var finalpass = new PasswordClass.fromJson(passMap);
      wifiPass = finalpass.password;

    }
    if(i == '2'){
      getResponse2 = await dio.get(url2);
      Map passMap2 = json.decode(getResponse2.toString());
      var finalpass2 = new PasswordClass.fromJson(passMap2);
      wifiPass2 = finalpass2.password;
    }
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-fi Config Screen'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
            print('Clicked Exit');
          },
          child: Text('Exit'),
          color: Colors.redAccent,
        ),
      ),
    );
  }
}


class RouterPage extends StatefulWidget {
  @override
  _RouterPageState createState() => _RouterPageState();
}



class _RouterPageState extends State<RouterPage>{
  ///For reading the inputted password and storing
  final readInputText = TextEditingController();
  final readMonthText = TextEditingController();
  TextEditingController currentPassword = TextEditingController();
  TextEditingController currentName = TextEditingController();
  String inputPassword = '';
  String inputMonth = '';
  String currentPasswordstr = '';// to be used in POST method to send json object
  String currentNamestr = '';
  String serverResponse = 'Server response';
  String url1 = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/?id=1';
  String url2 = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/?id=2';
  String url3 = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/?id=3';
  Dio dio = new Dio();
  

  onPressed(){
    setState((){
      inputPassword = readInputText.text;
      inputMonth = readMonthText.text;
    });
  }

  // For reading the inputted password and string
  final _readInputText1 = new TextEditingController();
  final _readInputText2 = new TextEditingController();

  int stringToInt(String month){
    switch (month){
      case "": {
        return 0;
      } break;
      case "January": {
        return 1;
      } break;
      case "February": {
        return 2;
      } break;
      case "March": {
        return 3;
      } break;
      case "April": {
        return 4;
      } break;
      case "May": {
        return 5;
      } break;
      case "June": {
        return 6;
      } break;
      case "July": {
        return 7;
      } break;
      case "August": {
        return 8;
      } break;
      case "September": {
        return 9;
      } break;
      case "October": {
        return 10;
      } break;
      case "November": {
        return 11;
      } break;
      case "December": {
        return 12;
      } break;
      default: {
        return -1;
      } break;
    }

  }

  //delete method
  String deletepass1;
  String deletemonth1;
  int deletecount1;
  String deletepass2;
  String deletemonth2;
  int deletecount2;

  //edit method
  final _readInputText3 = new TextEditingController();
  final _readInputText4 = new TextEditingController();
  String oldpass1;
  String oldmonth1;
  int  oldcount1;
  String oldpass2;
  String oldmonth2;
  int oldcount2;





  String dropDownValue1 = "";
  String dropDownValue2 = "";
  int count = 0;
  //password2
  final String passKey1 = "password1";
  final String passKey2 = "password2";
  final String monthKey1 = "month1";
  final String monthKey2 = "month2";
  final String countS = "count";
  String _realPass1 = "";
  String _final1 = "";
  String _realPass2 = "";
  String _final2 = "";

  void getPass1() {
    setState(() {
      _final1 = _realPass1;
      _readInputText1.clear();
    });
  }
  void getPass2(){
    setState(() {
      _final2 = _realPass2;
      _readInputText2.clear();
    });
  }

  save1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (stringToInt(dropDownValue1) < stringToInt(dropDownValue2)){
      prefs.setString(passKey1, _readInputText1.text);
      prefs.setString(passKey2, _readInputText2.text);
      prefs.setString(monthKey1, dropDownValue1);
      prefs.setString(monthKey2, dropDownValue2);
      prefs.setInt(countS, count);
    } else {
      prefs.setString(passKey1, _readInputText2.text);
      prefs.setString(passKey2, _readInputText1.text);
      prefs.setString(monthKey1, dropDownValue2);
      prefs.setString(monthKey2, dropDownValue1);
      prefs.setInt(countS, count);
    }
  }

  save2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstMonth = prefs.getString(monthKey1);
    if (stringToInt(dropDownValue1) < stringToInt(firstMonth)){
      String pass = prefs.getString(passKey1);
      prefs.setString(passKey1, _readInputText1.text);
      prefs.setString(passKey2, pass);
      prefs.setString(monthKey1, dropDownValue1);
      prefs.setString(monthKey2, firstMonth);
      prefs.setInt(countS, count);
    } else {
      prefs.setString(passKey2, _readInputText1.text);
      prefs.setString(monthKey2, dropDownValue1);
      prefs.setInt(countS, count);
    }
  }

  delete1() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //deletepass1 = prefs.get(passKey1);
    //deletemonth1 = prefs.get(monthKey1);
    prefs.remove(passKey1);
    prefs.remove(monthKey1);
    count--;
    //deletecount1 = prefs.getInt(countS);
    //deletecount1--;
    prefs.setInt(countS, count);
    Future<String> password1 = get1();
    password1.then((String p1) {
      _realPass1 = p1;
      //_passwords.add(_realPass1);
      getPass1();
    });


  }

  delete2() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //deletepass2 = prefs.get(passKey2);
    //deletemonth2 = prefs.get(monthKey2);
    prefs.remove(passKey2);
    prefs.remove(monthKey2);
    //deletecount2 = prefs.getInt(countS);
    count--;
    prefs.setInt(countS, count);
    Future<String> password2 = get2();
    password2.then((String p2) {
      _realPass2 = p2;
      //_passwords.add(_realPass2);
      getPass2();
    });


  }

  Future<String> edit1(BuildContext context) async{
    String newValue;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Change Password'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                      controller: _readInputText3,
                      autofocus: true,
                      decoration: new InputDecoration(
                          labelText: 'Enter Password',
                          hintText: 'New Password'
                      ),

                      onChanged: (value){
                        newValue = value;
                      },
                    )
                )
              ],
            ),

            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                onPressed: (){
                  oldpass1 = prefs.getString(passKey1);
                  oldmonth1 = prefs.getString(monthKey1);
                  oldcount1 = prefs.getInt(countS);
                  prefs.remove(oldpass1);
                  prefs.remove(oldmonth1);
                  prefs.setString(passKey1, _readInputText3.text);
                  prefs.setString(monthKey1, oldmonth1);
                  prefs.setInt(countS, oldcount1);
                  Navigator.of(context).pop(newValue);
                  Future<String> password1 = get1();
                  password1.then((String p1) {
                    _realPass1 = p1;
                    //_passwords.add(_realPass1);
                    getPass1();
                  });
                },
              )
            ],
          );
        }
    );
  }

  Future<String> edit2(BuildContext context) async{

    String newValue;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Change Password'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child:  new TextField(
                    autofocus: true,
                    controller: _readInputText4,
                    decoration: new InputDecoration(
                        labelText: 'Enter Password',
                        hintText: 'New password'
                    ),

                    onChanged: (value){
                      newValue = value;
                    },

                  ),
                )
              ],
            ),

            actions: <Widget>[

              FlatButton(
                child: Text('update'),
                onPressed: (){
                  Navigator.of(context).pop(newValue);
                  oldpass2 = prefs.getString(passKey1);
                  oldmonth2 = prefs.getString(monthKey1);
                  oldcount1 = prefs.getInt(countS);
                  prefs.remove(oldpass2);
                  prefs.remove(oldmonth2);
                  prefs.setString(passKey2, _readInputText4.text);
                  prefs.setString(monthKey2, oldmonth2);
                  prefs.setInt(countS, oldcount2);
                  Future<String> password2 = get2();
                  password2.then((String p2) {
                    _realPass2 = p2;
                    //_passwords.add(_realPass2);
                    getPass2();

                  });

                  //prefs.remove(passKey1);
                  //prefs.setString(passKey1, newValue);
                },
              )
            ],

          );
        }
    );
  }

  Future<String> get1() async {
    var password;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    password = prefs.getString(passKey1);
    return password;
  }

  Future<String> get2() async {
    var password;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    password = prefs.getString(passKey2);
    return password;
  }

  @override
  void initState() {
    super.initState();
    Future<String> password1 = get1();
    Future<String> password2 = get2();
    password1.then((String password) {
      _realPass1 = password;
      getPass1();
    });
    password2.then((String password) {
      _realPass2 = password;
      getPass2();
    });

  }


  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(title: new Text("Router Page"), backgroundColor: Colors.blueGrey[400]),
      body: new Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/BackgroundSupesLight.png'),
                fit: BoxFit.cover
            )
        ),
        child: new SingleChildScrollView(
                  child: Center(
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration:  InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 10.0),
                        icon:  Icon(Icons.perm_identity),
                        labelText: "Please input Wi-Fi name",
                        helperText: "name of Wi-Fi"),
                    controller: currentName,
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    child : Text("Set Name"),
                    onPressed: (){
                      Toast.show("The Name has been set", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      currentNamestr = currentName.text;
                      _makePostRequest('3');
                    },
                  ),
                   TextField(
                    decoration:  InputDecoration(
                        contentPadding: const EdgeInsets.only(top: 10.0),
                        icon:  Icon(Icons.perm_identity),
                        labelText: "Please input Wi-Fi password",
                        helperText: "WiFi Password for Current Month"),
                    controller: currentPassword,
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    child : Text("Set Password"),
                    onPressed: (){
                      Toast.show("The password has been set", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      currentPasswordstr = currentPassword.text;
                      _makePostRequest('1');
                    },
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: Text("Up to 2 passwords may be stored."),
                      margin: EdgeInsets.only(top: 25),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 12),
                    width: 450,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text("          "),
                                ),
                              ],
                            ),
                            Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text("Password 1"),
                                ),
                              ],
                            ),
                            Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text("Password 2"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text("Password: "),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 91,
                                  child: TextField(
                                      controller: _readInputText1 /*readInputText1*/,
                                      decoration: InputDecoration(
                                        hintText: "Password 1",
                                      )),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 91,
                                  child: TextField(
                                    decoration:
                                    InputDecoration(hintText: "Password 2"),
                                    controller: _readInputText2,
                                    enabled: (_readInputText1.text != ""),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text("Month: "),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 81,
                                  child: DropdownButton<String>(
                                    icon: Icon(Icons.calendar_today),
                                    iconSize: 10,
                                    elevation: 8,
                                    style: TextStyle(
                                        color: Colors.deepPurple
                                    ),
                                    underline: Container(
                                      height: 2,
                                      width: 5,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropDownValue1 = newValue;
                                      });
                                    },
                                    value: dropDownValue1,
                                    items: <String>[
                                      "",
                                      "January",
                                      "February",
                                      "March",
                                      "April",
                                      "May",
                                      "June",
                                      "July",
                                      "August",
                                      "September",
                                      "October",
                                      "November",
                                      "December"
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 81,
                                  child: IgnorePointer(
                                    ignoring: (dropDownValue1 == ""),
                                    child: DropdownButton<String>(
                                      icon: Icon(Icons.calendar_today),
                                      iconSize: 10,
                                      elevation: 8,
                                      style: TextStyle(
                                          color: Colors.deepPurple
                                      ),
                                      underline: Container(
                                        height: 2,
                                        width: 5,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      value: dropDownValue2,
                                      onChanged: (String newValue2) {
                                        setState(() {
                                          dropDownValue2 = newValue2;
                                        });
                                      },
                                      items: <String>[
                                        "",
                                        "January",
                                        "February",
                                        "March",
                                        "April",
                                        "May",
                                        "June",
                                        "July",
                                        "August",
                                        "September",
                                        "October",
                                        "November",
                                        "December"
                                      ].map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton(
                          child: Text("Save Password"),
                          color: Colors.blueAccent,
                          onPressed: () {
                            //must first check if already 2 passwords

                            if (count < 2) {
                              if ((_readInputText1.text != "") &&
                                  (_readInputText2.text != "")) {
                                if ((dropDownValue1 == "") &&
                                    (dropDownValue2 == "")) {
                                  Toast.show("Please enter a month for the password(s).",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                } else {
                                  count += 2;
                                  save1();
                                  Future<String> password1 = get1();
                                  password1.then((String p1) {
                                    _realPass1 = p1;
                                    //_passwords.add(_realPass1);
                                    getPass1();

                                  });
                                  Future<String> password2 = get2();
                                  password2.then((String p2) {
                                    _realPass2 = p2;
                                    //_passwords.add(_realPass2);
                                    getPass2();

                                  });

                                  Toast.show(
                                      "The passwords have been stored.",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              } else if ((_readInputText1.text != "")) {
                                if (dropDownValue1 == "") {
                                  Toast.show("Please enter a month for the password.",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                } else {
                                  count++;
                                  save2();
                                  Future<String> password1 = get1();
                                  password1.then((String p3) {
                                    _realPass1 = p3;
                                    //_passwords.add(_realPass1);
                                    getPass1();

                                  });
                                  Future<String> password2 = get2();
                                  password2.then((String p4) {
                                    _realPass2 = p4;
                                    //_passwords.add(_realPass2);
                                    getPass2();


                                  });
                                  Toast.show(
                                      "The password has been stored.",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              }
                            } else {
                              Toast.show(
                                  "You have already entered two passwords.", context,
                                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                            }

                          }
                      ),
                    ),
                  ),

                  ListView(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    children: <Widget>[
                      Align(
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            child: Text("Display Saved Passwords",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            margin: EdgeInsets.only(bottom: 10),
                          )


                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        height: 50,
                        color: Colors.blue,
                        child: Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: (){
                                      edit1(context);
                                      getPass1();
                                    }
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: (){
                                      setState(() {
                                        delete1();
                                        getPass1();
                                      });

                                    }
                                )
                              ],
                            ),

                            Column(
                              children: <Widget>[
                                Text('Password: $_final1',
                                  style:TextStyle(
                                      fontSize: 18,
                                      color: Colors.white
                                  ) ,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          height: 50,
                          color : Colors.blue,
                          child: Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: ()  {
                                        setState(() {
                                          edit2(context);
                                          getPass2();
                                        });
                                      }
                                  )
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed:(){
                                        setState(() {
                                          delete2();
                                          getPass2();
                                        });
                                      }
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Password: $_final2',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                      )
                    ],
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }


  _makePostRequest(var i) async {
    //put data from input field to replace '123456', the response of post is not used here, but just leave it there in case of error message in future.
    Response response2;
    if(i == '1'){response2 = await dio.post(url1, data: currentPasswordstr);}
    if(i == '3'){response2 = await dio.post(url3, data: currentNamestr);}
  }
}

class SetPasswordPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title : new Text('SetPasswordPage')),
        body : new Container(
            child: Center(
                child : Column(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.settings),
                        iconSize: 70,
                        onPressed: null
                    )
                  ],
                )
            )
        )
    );
  }
}


class UsePasswordPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(title: new Text('UsePasswordPage')),
        body : new Container(
            child : Center(
                child : Column(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.settings),
                        iconSize: 70,
                        onPressed: null)
                  ],

                )
            )
        )
    );
  }
}
class SavedPasswordPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title : new Text('SavedPasswordPage')),
        body : new Container(
            child: Center(
                child : Column(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.settings),
                        iconSize: 70,
                        onPressed: null
                    )
                  ],
                )
            )
        )
    );
  }
}

class PasswordClass {
  final String password;

  PasswordClass(this.password);

  PasswordClass.fromJson(Map<String, dynamic> json)
      : password = json['password'];

  Map<String, dynamic> toJson() =>
      {
        'password' : password,
      };
}
