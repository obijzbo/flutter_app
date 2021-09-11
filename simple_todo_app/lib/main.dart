import 'package:flutter/material.dart';
import 'package:simple_todo_app/screens/todo_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Todo list App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: TodoListScreeen(),
    );
  }
}