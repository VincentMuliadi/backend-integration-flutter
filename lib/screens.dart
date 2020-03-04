import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'dart:async';
import 'book.dart';
import 'app_localization.dart';
import 'package:country_code_picker/country_code_picker.dart';

var baseUrl = 'https://flutter-backend-training.herokuapp.com';
// var baseUrl = 'http://10.0.2.2:3000';
var urlVersion = baseUrl;
var urlLogin = '${baseUrl}/login';
var urlBooks = '${baseUrl}/books';

const countryList = ["Indonesia", "United States", "United Kingdom"];

final TextStyle titleStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

final TextStyle valueStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
  fontSize: 14,
);

class LoginScreen extends StatefulWidget {
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalStorage storage = new LocalStorage('myapp');
  final _formKey = GlobalKey<FormState>();
  var version = "";
  final Map<String, dynamic> formData = {'username': null, 'password': null};

  Future<String> fetchVersion() async {
    var res = await http.get(Uri.encodeFull(urlVersion),
        headers: {'accept': 'application/json'});
    setState(() {
      var content = json.decode(res.body);
      version = content['version'];
    });
  }

  Future<String> login() async {
    var res = await http.post(urlLogin,
        body: json.encode(formData),
        headers: {"Content-Type": "application/json"}).then((response) {
      // print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");
      var content = json.decode(response.body);
      if (response.statusCode == 200) {
        if (content['success']) {
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
    fetchVersion();

    return Scaffold(
      body: Center(
        child: Padding(
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
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).username),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      formData['username'] = value.trim();
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).password),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onSaved: (String value) {
                      formData['password'] = value.trim();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          // Process login
                          _formKey.currentState.save();
                          print(formData);

                          login().then((value) {
                            print(value.toString());
                            if (value == null) {
                              print('Login fail');
                            } else {
                              var access_token =
                                  storage.getItem("access_token");
                              print(
                                  'Login success. Access token: ${access_token}');

                              // Go to ListScreen
                              Navigator.pushNamed(context, "/list");
                            }
                          });
                        }
                      },
                      child: Text(AppLocalizations.of(context).login),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

class ListScreen extends StatefulWidget {
  static const routeName = '/list';

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final LocalStorage storage = new LocalStorage('myapp');

  String accessToken = "";

  // Prepare empty bookList
  List<Book> bookList = <Book>[];

  setAccessToken() {
    accessToken = storage.getItem("access_token");
  }

  Future<String> fetchBooks() async {
    var res = await http.get(Uri.encodeFull(urlBooks), headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer ${accessToken}'
    });

    print(res.body);

    setState(() {
      Iterable l = json.decode(res.body);

      bookList = l.map((model) => Book.fromJson(model)).toList();
    });
  }

  _buildItem(Book book) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text('${book.title}', style: titleStyle),
        ),
        Expanded(
          flex: 1,
          child:
              Text('${book.author} (${book.pages} pages)', style: valueStyle),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    setAccessToken();
    fetchBooks();
  }

  _gotoAdd() async {
    await Navigator.pushNamed(context, AddScreen.routeName);
    bookList.clear();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    var builder = ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: bookList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 70,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildItem(bookList[index]),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_right,
                      color: Colors.black54,
                      size: 24.0,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, DetailScreen.routeName,
                          arguments: bookList[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        });

    return Scaffold(
      appBar: AppBar(
        title: Text("Book List"),
      ),
      body: builder,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _gotoAdd();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  static const routeName = '/detail';

  _lineDetail(String label, value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: titleStyle,
          ),
        ),
        Text(
          '${value}',
          style: valueStyle,
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Book args = ModalRoute.of(context).settings.arguments;
    print(args.toJson());

    return Scaffold(
      appBar: AppBar(title: Text(args.title)),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _lineDetail("Author", args.author),
            _lineDetail("Total pages", args.pages),
            _lineDetail("Country", args.country),
            _lineDetail("Language", args.language),
            _lineDetail("Year", args.year),
          ],
        ),
      ),
    );
  }
}

class AddScreen extends StatefulWidget {
  static const routeName = '/add';

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    'title': null,
    'author': null,
    'country': 'Indonesia',
    'language': 'Indonesian'
  };

  _textEntry(
      String label, bool required, String requiredMessage, String formKey, [bool mustNumber = false]) {
    var _entry = Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: titleStyle),
          TextFormField(

            decoration: InputDecoration(hintText: ""),
            validator: (value) {
              if (required && value.isEmpty) {
                return requiredMessage;
              }
              if(mustNumber) {
                final isDigitsOnly = int.tryParse(value);
                return isDigitsOnly == null
                    ? 'Input needs to be digits only'
                    : null;
              }
              return null;
            },
            onSaved: (value) {
              if(mustNumber) {
                formData[formKey] = int.parse(value);
              } else {
                formData[formKey] = value;
              }
            },
          ),
        ],
      ),
    );

    return _entry;
  }

  _languageEntry(String label, bool required, String formKey) {
    var _entry = Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: titleStyle),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: DropdownButton<String>(
              isExpanded: true,
              value: formData[formKey],
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 24,
              style: TextStyle(color: Colors.black, fontSize: 16.0),
              underline: Container(
                height: 2,
                color: Colors.black,
              ),
              onChanged: (newValue) {
                setState(() {
                  formData[formKey] = newValue;
                });
              },
              items: <String>['Indonesian', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );

    return _entry;
  }

  _countryEntry(String label, bool required, String formKey) {
    var _entry = Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: titleStyle),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: new CountryCodePicker(
              onChanged: (CountryCode newValue) {
                setState(() {
                  formData[formKey] = newValue.name;
                });
              },
              // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
              initialSelection: 'ID',
              favorite: ['+62','ID'],
              showFlag: true,
              // optional. Shows only country name and flag
              showCountryOnly: true,
              // optional. Shows only country name and flag when popup is closed.
              showOnlyCountryWhenClosed: true,
              // optional. aligns the flag and the Text left
              alignLeft: false,
            ),
          ),
        ],
      ),
    );

    return _entry;
  }

  _formBuilder() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40, left: 40, right: 40),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _textEntry("Title", true, "Please enter title", "title"),
                _textEntry("Author", true, "Please enter author", "author"),
                _languageEntry("Language", false, "language"),
                _countryEntry("Country", true, "country"),
                _textEntry(
                    "Total Pages", true, "Please enter total pages", "pages", true),
                _textEntry("Year Published", true,
                    "Please enter year published", "year", true),
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Book"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Save',
            onPressed: () {
              // openPage(context);
              if (_formKey.currentState.validate()) {
                // Process save
                _formKey.currentState.save();
                print(formData);
              }
            },
          ),
        ],
      ),
      body: _formBuilder(),
    );
  }
}
