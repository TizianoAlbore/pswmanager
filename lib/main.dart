theme: ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color.fromARGB(255, 26, 24, 24),
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: Colors.purple,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
    headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.purple,
    foregroundColor: Colors.white,
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Colors.white70, size: 24),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white38),
  ),
),
