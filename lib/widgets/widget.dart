import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Text('Commune'),
  );
}

InputDecoration textFieldInputDecoration (String x)
{
  return InputDecoration(
      hintText: x,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            color: Colors.blueAccent
        ),
      )
  );
}