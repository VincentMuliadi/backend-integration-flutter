import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'dart:async';

// var baseUrl = 'https://flutter-backend-training.herokuapp.com';
var baseUrl = 'http://10.0.2.2:3000';
var urlVersion = baseUrl;
var urlLogin = '${baseUrl}/login';

class LoginScreen extends StatefulWidget {

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalStorage storage = new LocalStorage('myapp');
  final _formKey = GlobalKey<FormState>();
  var version = "";
  final Map<String, dynamic> formData = {'username': null, 'password': null};

  Future<String> fetchVersion() async {
    var res = await http.get(Uri.encodeFull(urlVersion), headers: { 'accept':'application/json' });
    setState(() {
      var content = json.decode(res.body);
      version = content['version'];
    });
  }

  Future<String> login() async {
    var res = await http.post(urlLogin, body: json.encode(formData), headers: {"Content-Type": "application/json"})
        .then((response) {
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      var content = json.decode(response.body);
      if(response.statusCode == 200) {
        if ( content['success'] ) {
          storage.setItem("access_token", content['accessToken']);
          return "success";
        }
      }
      return "fail";
    });

    return res;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold (
      body: Center(
        child: Padding (
          padding: EdgeInsets.only(top: 120, left: 40, right: 40),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'App Version ${version}',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'Username'
                    ),
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    onSaved: (String value){
                      formData['username'] = value.trim();
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Password'
                    ),
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onSaved: (String value){
                      formData['password'] = value.trim();
                    },
                  ),
                  Padding (
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton (
                      onPressed: () {
                        if( _formKey.currentState.validate()) {
                          // Process login
                          _formKey.currentState.save();
                          print(formData);

                          login().then((value){
                            print(value.toString());
                            if( value == null ) {
                              print('Login fail');
                            } else {
                              var access_token = storage.getItem("access_token");
                              print('Login success. Access token: ${access_token}');

                              // Go to ListScreen
                            }
                          });
                        }
                      },
                      child: Text("Login"),
                    ),
                  )
                ],
              )
          ),
        ),

      ),
    );
  }
}

class ListScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}

class DetailScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}