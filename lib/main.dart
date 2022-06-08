/* main function entry */
import 'package:bp_notepad/events/reminderBloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:bp_notepad/screens/mainScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bp_notepad/localization/languageConstants.dart';
import 'package:bp_notepad/localization/appLocalization.dart';

List sysSupportedLocales = []; //Since there is more than one environment language read, an array is added to save

void main() {
  runApp(BpNotepad());
}

class BpNotepad extends StatefulWidget {
  const BpNotepad({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _BpNotepadState state = context.findAncestorStateOfType<_BpNotepadState>();
    state.setLocale(newLocale);
  }

  @override
  _BpNotepadState createState() => _BpNotepadState();
}

class _BpNotepadState extends State<BpNotepad> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReminderBloc>(
        create: (context) => ReminderBloc(),
        child: CupertinoApp(
            debugShowCheckedModeBanner: false,
            locale: _locale,
            supportedLocales: [
              Locale("en", ""),
              Locale("zh", ""),
            ],
            // localized representative
            // The delegates collectively define all of the localized resources for this application's Localizations widget.
            // Delegates are equivalent to a bridge between Flutter and localization
            localizationsDelegates: [
              // First parse the json
              AppLocalization.delegate,
              // Built in
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // localization logic, return the local to use, check whether the language we need to use is in supportedLocales
            localeResolutionCallback: (locale, supportedLocales) {
              sysSupportedLocales.add(locale.languageCode);
              for (var supportedLocale in supportedLocales) {
                // Choose your preferred language for language settings
                if (supportedLocale.languageCode == sysSupportedLocales.first) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            title: "BP Notepad",
            // theme: ThemeData.dark().copyWith(
            //     //Color themes: .dark is dark mode, .light is light mode
            //     primaryColor: const Color(0xFF0A0E21), //Color: The main color of the whole theme
            //     scaffoldBackgroundColor: const Color(0xFF0A0E21)), //颜色:background color
            home: MyHomePage()));
  }
}
