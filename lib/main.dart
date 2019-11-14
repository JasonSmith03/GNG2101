import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(title: 'AutoConnect', home: MainActivity(),
    routes: <String, WidgetBuilder>{
      '/SetPasswordPage' : (BuildContext context) => new SetPasswordPage(),
      '/UsePasswordPage' : (BuildContext context) => new UsePasswordPage(),
      '/SavedPasswordPage' : (BuildContext context) => new SavedPasswordPage()
    }));

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State {

  String msg = 'Autoconnect: OFF';
  String pass = 'admin';
  String serverResponse = 'pending...'; //password for the wifi from server

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
    Response response = await get(_localhost());
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    String json = response.body;
    setState(() {
      serverResponse = json;
    });
  }
  String _localhost() {
    if (Platform.isAndroid)
      return 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/';
    else // for iOS simulator
      return 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/';
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
  String currPass = ''; //store the entered password value; used with currentPassword Controller
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
              ),
              RaisedButton(
                color: Colors.blue,
                child : Text("Set Password"),
                onPressed: (){
                  Toast.show("The password has been set", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  currPass = currentPassword.text;
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
  //TODO post to server
  _makePostRequest() async {
  // set up POST request arguments
  String url = 'http://ec2-35-182-74-15.ca-central-1.compute.amazonaws.com:9000/';
  Map<String, String> headers = {"content-type": "application/json"};
  String json = '{"title": "keyword", "body": currPass}';
  // make POST request
  Response response = await post(url, headers: headers, body: json);
  // check the status code for the result
  int statusCode = response.statusCode;
  // this API passes back the id of the new item added to the body
  String body = response.body;
   setState(() {
      currentPasswordstr = body;
    });
  // {
  //   "title": "Hello",
  //   "body": "body text",
  //   "userId": 1,
  //   "id": 101
  // }
}

}


class SetPasswordPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title : new Text('SetPasswordPage'),backgroundColor: Colors.deepOrangeAccent),
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
        appBar: new AppBar(title: new Text('UsePasswordPage'), backgroundColor: Colors.deepOrangeAccent),
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
        appBar: new AppBar(title : new Text('SavedPasswordPage'),backgroundColor: Colors.deepOrangeAccent),
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

