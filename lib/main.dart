import 'package:flutter/material.dart';
import 'package:flutter_moor_tutorial/data/moor_database.dart';
import 'package:provider/provider.dart';

import './page/home_page.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Provider(
      builder: (context) => AppDatabase(),
      child: MaterialApp(
        title: 'Flutter Moor',
        home: HomePage(),
      ),
    );
  }
}
