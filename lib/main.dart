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

//String WIFI_SSID = "421 Nelson";
//String WIFI_SSID = "AndroidWifi";

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

  //String ssid1 = "WIN-BFFP4MARMKN 5784";
  //String ssid2 = "AndroidWifi";
  //String ssid3 = "421 Nelson";
  String WIFI_SSID = "AndroidWifi";
  //T;77666d
  String msg = "Autoconnect: OFF";
  String msg2 = "";
  String pass = "a";

  String nextMonthPass = "T;77666d";
  bool statusAC = false;




  _MainActivityState() {
    _connectivity = new Connectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(onConnectivityChange);
  }

  String wifiPass = "";
  String serverResponse = 'pending...'; //password for the wifi from server
  String nextServerResponse = 'pending...'; //password for the wifi from server
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
              Text(
                msg2,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
              RaisedButton(
                child: Text('AutoConnect'),
                onPressed: (){
                  _makeGetRequest();
                  setState(() {
                    if (statusAC == true) {

                      msg = 'Autoconnect: OFF';
                      statusAC = false;

                      serverResponse = 'pending...';
                      print(serverResponse);
                    }
                    else if (statusAC == false) {

                      statusAC = true;
                      msg = 'Autoconnect: ON';

                      serverResponse = wifiPass;
                      print(serverResponse);


                      connectingTest();
                    }
                  });

                },
                  color: Colors.blue,
                textColor: Colors.black,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
            RaisedButton(
                child: Text('idk'),
                onPressed: (){
                  _launchURL();
                  //checkPassStatus();
                }
            ),
              //Server response text 
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text(status),
                child: Text('Password: ' + serverResponse),
                //child: Text('Password: ' + WIFI_PASSWORD),
              ),

              //Next Server response text 
              Padding(
                padding: const EdgeInsets.all(8.0),
                //child: Text(status),
                child: Text('Password: ' + nextServerResponse),
                //child: Text('Password: ' + WIFI_PASSWORD),
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
//
//  activateAC() {
//    setState(() {
//      statusAC = true;
//      msg = 'Autoconnect: ON';
//      serverResponse = _makeGetRequest();
//      //assigns retrieved pass to password variable
//      WIFI_PASSWORD = serverResponse;
//      //msg2 = serverResponse;
//    });
//
//  }
//
//  deactivateAC() {
//    setState(() {
//      statusAC = false;
//      msg = 'Autoconnect: OFF';
//
//      serverResponse = 'pending...';
//      //msg2 = serverResponse;
//    });
//  }
//

  void onConnectivityChange(ConnectivityResult result) {

    print("CONNECTION STATE CHANGED"+ serverResponse);
    if(statusAC == true) {
      _checkInternetConnectivity();
    }


  }


  connectingTest() {
    WiFiForIoTPlugin.connect(
      WIFI_SSID,
      password: serverResponse,
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

  _makeGetRequest() async {
    Response response = await dio.get(url);
    //these two line of code below are for extracting data from json through object
    Map passMap = json.decode(response.toString());
    var finalpass = new PasswordClass.fromJson(passMap);
    wifiPass = finalpass.password;

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
  String dropDownValue = 'one';

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
