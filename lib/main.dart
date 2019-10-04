import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
<<<<<<< HEAD
      title: 'Autoconnect', home: new HomePage(title: 'Autoconnect!')

=======
      title: 'Autoconnect', home: new HomePage(title: 'Autoconnect!!')
>>>>>>> release/Jason_Branch
    );
  }
}

class HomePage extends StatelessWidget{
  final String title;

  HomePage({this.title});

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(title: new Text(this.title)),
      body: new LandingPage());
  }
}

class LandingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new Container(
      child: Align (
        alignment: Alignment.center,
        child: new RaisedButton(
          child: Text('Autoconnect'), //name of button
      onPressed: () {} //when button is pressed it has to do something
      ),)
    );

  
  }
}