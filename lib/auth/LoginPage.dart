import 'package:flutter/material.dart';
import 'package:note_vault_frontend/admin/AdminPanel.dart';
import 'package:note_vault_frontend/auth/RegistrationPage.dart';
import 'package:note_vault_frontend/screens/EditorPage.dart';
import '/services/ApiServices.dart';

class LoginPage extends StatelessWidget{
  final usernameController= TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child:Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                ),
              ),
              ElevatedButton(onPressed:() async{

                final username=usernameController.text;
                final password=passwordController.text;
                print("Email : $username and Password : $password");
                if(username=="admin123@gmail.com" && password=="admin@123"){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>Adminpanel(title:"Admin Panel")),
                  );
                }
                bool result = await ApiServices.loginUser(username,password);
                if(result){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>EditorPage()),
                  );
                }
                else{
                  // Here i wanna to show a message first and then move to another screen
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("First Register yourself !! ")));

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>RegistrationPage()),
                  );
                }
              }, child:Text("Login"))
            ],
          ),
        ),
      ),
    );
  }
}