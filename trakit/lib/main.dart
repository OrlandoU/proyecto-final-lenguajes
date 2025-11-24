import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/views/auth/user_view.dart';
import 'package:trakit/client/views/dashboard/dashboard_view.dart';
import 'package:trakit/client/views/goals/create_goal.dart';
import 'package:trakit/client/views/goals/goal_details.dart';
import 'package:trakit/client/views/goals/goals_view.dart';
import 'package:trakit/client/views/goals/week_update.dart';
import 'package:trakit/client/views/home/home_page.dart';
import 'package:trakit/client/views/auth/login_view.dart';
import 'package:trakit/client/views/goals/select_goal.dart';
import 'package:trakit/client/views/auth/signup_view.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/src/firebase/firestore_service.dart';
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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.greenAccent)),
      routerConfig: GoRouter(
        initialLocation: '/',
        redirect: (context, state) async {
           final user = FirebaseAuth.instance.currentUser;

           final freeRoutes = {'/signup'};

           if (user == null && !freeRoutes.contains(state.fullPath)) {
             return '/login';
          }
          if (user != null && state.fullPath == '/') {
                final goalsSnapshot = await FirestoreService().getGoals(userId: user.uid);
                if (goalsSnapshot.isEmpty) {
                  
                  return '/new_goal'; // Redirige al crear primer objetivo
                }
              }
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
            builder: (context, state) => SelectGoalView(),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => DashboardView(),
          ),
          GoRoute(
            path: '/create-goal',
            name: 'create-goal',
            builder: (context, state) {
              final mode = state.extra as String;
              return CreateGoalView(mode: mode);
            },
          ),
          GoRoute(
            path: '/user',
            name: 'user',
            builder: (context, state) => UserView(),
          ),
          GoRoute(
            path: '/goals',
            name: 'goals',
            builder: (context, state) => GoalsView(),
          ),
          GoRoute(
            path: '/goal-details',
            name: 'goal-details',
            builder: (context, state) {
              final goal = state.extra as Goal;
              return GoalDetailsView(goal: goal);
            },
          ),
          GoRoute(
            path: '/week-update',
            name: 'week-update',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>;
              return SubmitWeekAmountView(
                week: data['weekNumber'] as int,
                expectedAmount: data['expectedAmount'] as double,
                onSubmit: (double value) {
                },
                realAmount: data['realAmount'],
                id: data['id']
              );
            },
          ),
        ],
      ),
    );
  }
}
