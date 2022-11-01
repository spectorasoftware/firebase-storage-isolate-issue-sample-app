import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
Future<void> computeFunction(String arg) async {
  print('running in isolate');
  return Future.value();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await FirestoreService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: upload,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// This method loads a file from assets and uploads to Firebase Storage.
  Future<void> upload() async {
    setState(() => _counter++);

    // Trigger computation in Isolate
    await flutterCompute(computeFunction, "foo");

    // Load a file to upload
    final z = DateTime.now().millisecondsSinceEpoch;
    final tmp = await getTemporaryDirectory();
    final data = await rootBundle.load('assets/dell.jpg');
    final buffer = data.buffer;
    final file = await File('${tmp.path}/test.jpg').writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

    // Upload the file.
    print('[UPLOAD STARTED]');

    final imageBucket = FirebaseStorage.instance;
    try {
      await imageBucket.ref('test-$z.jpg').putFile(file);
    } catch (e) {
      print(e);
    }

    // When an isolate has been triggered prior to upload, you'll
    // never get to this point. If you comment out the isolate, you'll need
    // to kill the app and restart it to get it working again.
    print('[UPLOAD DONE]');
  }
}

/// A small service to initialize a Firebase app instance.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;
  late final FirebaseApp app;

  final options = const FirebaseOptions(
    appId: '1:218287927002:ios:a6d27b71f0cb14ee1a3fe3',
    apiKey: 'AIzaSyCGxZzl9PKhBYXYoqJHorpovqH13O2xr3Q',
    projectId: 'fir-storage-ios-issue',
    messagingSenderId: '218287927002',
    storageBucket: 'fir-storage-ios-issue',
  );

  Future<void> init() async {
    app = await Firebase.initializeApp(
      name: 'fir-storage-ios-issue',
      options: options,
    );
  }
}
