import 'package:flutter/material.dart';
import 'package:note_vault_frontend/admin/CreateNewUser.dart';
import 'package:note_vault_frontend/admin/DeleteUser.dart';
import 'package:note_vault_frontend/admin/UpdateUser.dart';
import 'package:note_vault_frontend/widgets/tiles/TileBox.dart';
import 'UsersPage.dart';
import 'UserPage.dart';
import '/admin/AdminPanel.dart';

class Adminpanel extends StatelessWidget {
  final String title;
  Adminpanel({super.key, required this.title});

  final List<String> labels=[
    "Users","User","New User", "Update User","Delete User"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(title),
        ),
        body:Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: labels.map((label) {
                return TileBox(
                  label: label,
                  onTap: () {
                    if (label == "Users") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersPage()),
                      );
                    }
                    if(label=="User"){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder:(context)=>UserPage())
                      );
                    }
                    if(label=="New User"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>CreateNewUser())
                      );
                    }

                    if(label=="Delete User"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>DeleteUser())
                      );
                    }
                    if(label=="Update User"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>UpdateUser())
                      );
                    }
                    // You can add more conditions for other labels later
                  },
                );
              }).toList(),
            )
        ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


