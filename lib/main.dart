import 'package:flutter/material.dart';
import 'screens.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localization.dart';

void main() => runApp(
    MyApp()
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en','US'), // English
        const Locale('id','ID'), // Indonesian
        // ... other locales the app supports
      ],
      localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
        if(locale!=null) {
          for (var supportedLocale in supportedLocales) {
            if (locale.countryCode == supportedLocale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.elementAt(0);
        }
        return locale;
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/list': (context) => ListScreen(),
        DetailScreen.routeName: (context) => DetailScreen(),
      },
    );
  }
}