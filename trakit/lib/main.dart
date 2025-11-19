import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/views/dashboard.dart';
import 'package:trakit/client/views/home_page.dart';
import 'package:trakit/client/views/login.dart';
import 'package:trakit/client/views/new_goal.dart';
import 'package:trakit/client/views/signup.dart';
import 'package:trakit/src/firebase/auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.greenAccent),
      ),
      routerConfig: GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          // Aquí puedes agregar lógica de redirección basada en la autenticación
          // final user = FirebaseAuth.instance.currentUser;

          // final freeRoutes = {'/signup'};

          // if (user == null && !freeRoutes.contains(state.fullPath)) {
          //   return '/login';
          // }

          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => HomeView(),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => LoginPage(),
            ),
          GoRoute(
            path: '/signup',
            name: 'signup',
            builder: (context, state) => SignupPage(),
          ),
          GoRoute(
            path: '/new_goal',
            name: 'new_goal',
            builder: (context, state) => NewGoalView(),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => DashboardView(),
          )
        ]
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    signInWithGoogle();
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
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
