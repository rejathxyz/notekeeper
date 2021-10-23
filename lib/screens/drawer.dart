import 'package:flutter/material.dart';
class DrawerScree extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          DrawerHeader(child: Text("Note Keeper"),),
          ListTile(title: Text("Notes"),),
          ListTile(title: Text("Archives"),),
          ListTile(title: Text("Trash"),),
        ],
      ),
    );
  }
}