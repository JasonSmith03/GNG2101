import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new MaterialApp(home: new PasswordDiplay()));
}

class PasswordDiplay extends StatefulWidget{

  @override
  MyApp createState() => new MyApp();
}

class MyApp extends State<PasswordDiplay> {
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
  Widget build(BuildContext context) {
    
    return new Builder(builder: (BuildContext context) {
      return new Scaffold(
        appBar:  AppBar(
          title:  Text("Password settings"),
        ),
        body:  Center(
          child: new Builder(builder: (BuildContext context){
            return
                Column(
                  children: <Widget>[
                     TextField(
                      controller: _passwordController,
                      decoration:  InputDecoration(
                          contentPadding: const EdgeInsets.only(top: 10.0),
                          icon:  Icon(Icons.perm_identity),
                          labelText: "please input password",
                          helperText: "password of Wi-Fi"),
                    ),
                    RaisedButton(
                        color: Colors.blueAccent,
                        child: Text("save"),
                        onPressed: () {
                          save();
                          Future<String> password = get();
                          password.then((String password) {
                            _realPass = password;
                            getPass();
                          });
                          Scaffold.of(context).showSnackBar(
                              new SnackBar(content:  Text("password is saved successfully")));
                        }),
                    new Text('password: $_final'),
                  ],
                );
          }),
        ),
      );
    });
  }
}