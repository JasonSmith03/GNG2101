import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MaterialApp(title: "AutoConnect", home: MainActivity(),
    routes: <String, WidgetBuilder>{
      "/SetPasswordPage" : (BuildContext context) => new SetPasswordPage(),
      "/UsePasswordPage" : (BuildContext context) => new UsePasswordPage(),
      "/SavedPasswordPage" : (BuildContext context) => new SavedPasswordPage()
    }));

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State {

  String msg = 'Autoconnect: OFF';
  String pass = 'admin';

  Future<String> createAlertDialog(BuildContext context){

    TextEditingController customController = TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Enter Password"),
        content: TextField(
          controller: customController,
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text("Enter"),
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
    String serverResponse = 'Password: ';
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('AutoConnect'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
              RaisedButton(
                child: Text("AutoConnect"),
                onPressed: (){
                  setState(() {
                    if (msg == 'Autoconnect: ON') {
                      msg = 'Autoconnect: OFF';
                      _makeGetRequest();
                    }
                    else if (msg == 'Autoconnect: OFF') {
                      msg = 'Autoconnect: ON';
                    }
                  });
                },
                color: Colors.blueAccent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),

              //Server response text 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(serverResponse),
              ),

              RaisedButton(
                child: Text("Admin"),
                color: Colors.grey,
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

  _makeGetRequest() async {
      Response response = await get(_localhost());
      setState(() {
      serverResponse = response.body;
    });
  }

  String _localhost() {
    if (Platform.isAndroid)
      return 'http://ec2-3-15-208-145.us-east-2.compute.amazonaws.com:9000/';
    else // for iOS simulator
      return 'http://ec2-3-15-208-145.us-east-2.compute.amazonaws.com:9000/';
  }
}

//  other() {
//    setState(() {
//   msg = 'AutoConnecting...';
//    });
//  }
//

}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wi-fi Config Screen"),
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


class RouterPage extends StatelessWidget {
  @override

  Widget build(BuildContext context){
        return new Scaffold(
            appBar: new AppBar(title: new Text("Router Page"), backgroundColor: Colors.deepOrangeAccent),
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
                              decoration: InputDecoration(hintText: "current wifi password"),
                            ),
                            )
                          ]),
                          ),
                      
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: RaisedButton(
                            child : Text("Use Password"),
                            color : Colors.green,
                            onPressed: (){}
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
                                      decoration: InputDecoration(hintText: "Enter wifi password"),
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
                                      decoration: InputDecoration(hintText: "password Month"),
                                    ),
                                  )
                                ]),
                          ),


                          Align(
                            alignment: Alignment.bottomCenter,
                            child: RaisedButton(
                                child : Text("Set Password"),
                                color : Colors.green,
                                onPressed: (){}
                            ),
                          ),


                          //Add  text to say "Passwords to send"

                          new Text(
                              "Passwords to Send",
                              style: TextStyle(
                                fontSize: 26.0,

                              ),
                          ),

                          GestureDetector(
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('October:',
                                      style: TextStyle(
                                      fontSize: 22.0,

                                   )
                                  ),
                                  ),
                                  Expanded(
                                    child : Text('Soccer123',
                                        style: TextStyle(
                                          fontSize: 22.0,

                                        )
                                    ),
                                  )
                                ]),
                          ),

                          GestureDetector(
                            child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('November:',
                                     style: TextStyle(
                                       fontSize: 22.0,

                                   )
                                    ),
                                  ),
                                  Expanded(
                                    child: Text('Hospital321',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                        )

                                    ),
                                  )
                                ]),
                          ),
                          
                    ]
                )
 //           )
        )
    );
  }
}

class SetPasswordPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title : new Text("SetPasswordPage"),backgroundColor: Colors.deepOrangeAccent),
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
        appBar: new AppBar(title: new Text("UsePasswordPage"), backgroundColor: Colors.deepOrangeAccent),
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
        appBar: new AppBar(title : new Text("SavedPasswordPage"),backgroundColor: Colors.deepOrangeAccent),
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

