import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_list/animatedList.dart';
import 'package:todo_list/listview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // home: const TodoAppAnimatedList(),
      home: const TodoAppListview(),
    );
  }
}
