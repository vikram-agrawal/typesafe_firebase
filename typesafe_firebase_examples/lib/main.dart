import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:typesafe_firebase/typesafe_firebase.dart';
import 'package:typesafe_firebase_examples/functions/functions_example.dart';
import 'package:typesafe_firebase_examples/register_models.g.dart';

void main() {
  const FirebaseOptions options = FirebaseOptions(
    apiKey: 'APIKEY',
    appId: '1:2:web:3',
    messagingSenderId: '45432432',
    projectId: 'demo-typesage-firebase',
    storageBucket: 'demo-typesage-firebase.firebasestorage.app',
  );
  Firebase.initializeApp(options: options);
  FirebaseProvider.setConfig(emulatorIp: "localhost");
  registerAllModels();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'TypeSafe Firebase Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _userIdController = TextEditingController();

  String _userName = "No user fetched yet";

  void _fetchUserName() async {
    String input = _userIdController.text.trim();
    String userName;
    if (input.isEmpty) {
      userName = "Please enter a User ID";
    } else {
      // Replace this with an actual API call using the 'http' package
      userName = await getUserName(input);
    }
    setState(() {
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            // Input view for User ID
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: "Enter User ID",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Button to trigger fetch
            ElevatedButton(
              onPressed: _fetchUserName,
              child: const Text("Fetch User Name"),
            ),
            const SizedBox(height: 30),

            // Display view for User Name
            Text(
              _userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
