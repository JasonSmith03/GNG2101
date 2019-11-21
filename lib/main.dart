import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  String msg = 'Autoconnect: OFF';
  String pass = 'admin';
  String serverResponse = 'pending...'; //password for the wifi from server
  String nextServerResponse = 'pending...'; //next month password from server
  String url = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/';
  Dio dio = new Dio();

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
              Text(
                msg,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
              RaisedButton(
                child: Text('AutoConnect'),
                onPressed: (){
                  setState(() {
                    if (msg == 'Autoconnect: ON') {
                      msg = 'Autoconnect: OFF';
                      serverResponse = 'pending...';
                    }
                    else if (msg == 'Autoconnect: OFF') {
                      msg = 'Autoconnect: ON';
                      serverResponse = _makeGetRequest();
                      nextServerResponse = _makeGetRequest();
                    }
                  });
                },
                color: Colors.blue,
                textColor: Colors.black,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),

              //Server response text
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text(status),
                child: Text('Password: ' + serverResponse),
              ),

              //Next response text
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text(status),
                child: Text('Password: ' + nextServerResponse),
              ),

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

  _makeGetRequest() async {
    Response response = await dio.get(url);
    //these two line of code below are for extacting data from json through object
    Map passMap = json.decode(response.toString());
    var finalpass = new PasswordClass.fromJson(passMap);
    setState(() {
      serverResponse = finalpass.password;
    });
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
  String inputPassword = '';
  String inputMonth = '';
  String currentPasswordstr = '';// to be used in POST method to send json object
  String serverResponse = 'Server response';
  String url = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/';
  Dio dio = new Dio();
  //int counter = 0;
  //var values = ["", ""];

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
  String deletepass2;
  String deletemonth2;

  //edit method
  final _readInputText3 = new TextEditingController();
  final _readInputText4 = new TextEditingController();
  String oldpass1;
  String oldmonth1;
  String oldpass2;
  String oldmonth2;





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
    //prefs.remove(monthKey1);
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
                  prefs.remove(oldpass1);
                  prefs.remove(oldmonth1);
                  prefs.setString(passKey1, _readInputText3.text);
                  prefs.setString(monthKey1, oldmonth1);
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
                  prefs.remove(oldpass2);
                  prefs.remove(oldmonth2);
                  prefs.setString(passKey2, _readInputText4.text);
                  prefs.setString(monthKey2, oldmonth2);
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






  /*
  String dropDownValue = 'one'; //delete

  final String mPass = "password";
  final _passwordController = new TextEditingController();
  String _realPass = "";
  String _final = "";
  void getPass() {
    setState(() {
      _final = _realPass;
      _passwordController.clear();
    });
  }

  save() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(mPass, _passwordController.value.text.toString());
  }

  Future<String> get() async {
    var password;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    password = prefs.getString(mPass);
    return password;
  }

  @override
  void initState() {
    super.initState();
    Future<String> password = get();
    password.then((String password) {
      _realPass = password;
      getPass();
    });
  }
  */

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
        child: Center(
            child: Column(
              children: <Widget>[
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
                    _makePostRequest();
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
                        child: Text("Set Password"),
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

                          //_passwords = [_final1, _final2];
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
                              Text('password: $_final1',
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







                /*
              TextField(
                controller: _passwordController,
                decoration:  InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 10.0),
                    icon:  Icon(Icons.perm_identity),
                    labelText: "Please input password",
                    helperText: "Password of Wi-Fi"),
              ),

              DropdownButton<String>(
                icon: Icon(Icons.calendar_today),
                iconSize: 24,
                hint: Text("Select Password Month"),
                value: dropDownValue,
                items: [
                  DropdownMenuItem<String>(
                    value: 'one',
                    child: Text('January'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'two',
                    child: Text('February'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'third',
                    child: Text('March'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'four',
                    child: Text('April'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'five',
                    child: Text('May'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'six',
                    child: Text('June'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'seven',
                    child: Text('July'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'eight',
                    child: Text('August'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'nine',
                    child: Text('September'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'ten',
                    child: Text('October'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'eleven',
                    child: Text('November'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'twelve',
                    child: Text('December'),
                  ),
                ],

                onChanged: (String value){
                  setState(() {
                    dropDownValue = value;
                  });
                },
              ),

              RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Save"),
                  onPressed: () {
                    Toast.show("Password has been saved", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

                    /*if (readMonthText.text != ""){
                      onPressed();
                      Toast.show("The password has successfully been stored!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    } else {
                      Toast.show("Please a month for the password.", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }
                  }*/
                    save();
                    Future<String> password = get();
                    password.then((String password) {
                      _realPass = password;
                      getPass();
                    }
                    );
                  }),
              new Text('password: $_final'),
              */
              ],
            )
        ),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context){
        return new Scaffold(
            appBar: new AppBar(title: new Text('Router Page'), backgroundColor: Colors.deepOrangeAccent),
            body: new Container(
 //               child: Center(
                    child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                            Expanded(
                              child: Text('Password:'),
                              ),
                            Expanded(
                              child: TextField(
                                controller: currentPassword,
                                decoration: InputDecoration(hintText: 'current wifi password'),
                            ),
                            )
                          ]),
                          ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: RaisedButton(
                            child : Text('Use Password'),
                            color : Colors.green,
                            onPressed: (){
                              currentPasswordstr = currentPassword.text;
                              _makePostRequest();
                            }
                          ),
                        ),
                      // new RaisedButton(
                      //     child : new Text("Saved Passwords"),
                      //     color : Colors.pinkAccent,
                      //     onPressed: (){Navigator.of(context).pushNamed("/UsePasswordPage");}
                      // )
                          GestureDetector(
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Password:'),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(hintText: 'Enter wifi password'),
                                      controller: readInputText,
                                    ),
                                  )
                                ]),
                          ),

                          GestureDetector(
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Month:'),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(hintText: 'password Month'),
                                      controller: readMonthText,
                                    ),

                                  )
                                ]),
                          ),


                          Align(
                            alignment: Alignment.bottomCenter,
                            child: RaisedButton(
                                child : Text('Set Password'),
                                color : Colors.green,
                                onPressed: (){
                                  if (readMonthText.text != ''){
                                    onPressed();
                                    Toast.show('The password has successfully been stored!', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                  } else {
                                    Toast.show('Please a month for the password.', context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                  }
                                }
                            ),
                          ),


                          //Add  text to say "Passwords to send"
                          new Text(
                            'Passwords to Save',
                             style : TextStyle(
                              fontSize : 26.0,
                          )

                          ),

                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: new Text(
                              inputMonth + '          :          ' + inputPassword,
                              style: TextStyle(
                                fontSize: 36,
                              ),
                            ),

                          ),

                    ]
                )
            )
        )
    );
  }
 */
  _makePostRequest() async {
    //put data from input field to replace '123456', the response of post is not used here, but just leave it there in case of error message in future.
    await dio.post(url, data: currentPasswordstr);
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
