import 'package:dart_flutter/Navigation.dart';
import 'package:dart_flutter/custom_classes/group.dart';
import 'package:dart_flutter/custom_classes/task.dart';
import 'package:dart_flutter/screens/Auth.screen.dart';
import 'package:dart_flutter/screens/Group.screen.dart';
import 'package:dart_flutter/screens/Home.screen.dart';
import 'package:dart_flutter/screens/Image.screen.dart';
import 'package:dart_flutter/screens/Init.screen.dart';
import 'package:dart_flutter/screens/Search.screen.dart';
import 'package:dart_flutter/screens/Task.screen.dart';
import 'package:dart_flutter/screens/Tasks.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route<dynamic> myOnGenerateRoute(RouteSettings settings){
  switch(settings.name){
    case '/init':
      return CupertinoPageRoute(
          builder:  routes['/init']!,
          settings: settings
      );
    case '/auth':
      return CupertinoPageRoute(
          builder:  routes['/auth']!,
          settings: settings
      );
    case '/home':
      return MaterialPageRoute(
          builder:  routes['/home']!,
          settings: settings
      );
    case '/my-tasks':
      return CupertinoPageRoute(
          builder:  routes['/my-tasks']!,
          settings: settings
      );
    case '/image':
      return MaterialPageRoute(
          builder: routes['/image']!,
          settings: settings
      );
    case '/image-with-task':
      return MaterialPageRoute(
          builder: routes['/image-with-task']!,
          settings: settings
      );
    case '/group-tasks':
      return CupertinoPageRoute(
          builder: routes['/group-tasks']!,
          settings: settings
      );
    case '/group':
      return CupertinoPageRoute(
          builder: routes['/group']!,
          settings: settings
      );
    case '/search':
      return CupertinoPageRoute(
          builder: routes['/search']!,
          settings: settings
      );
    case '/task':
      return CupertinoPageRoute(
          builder: routes['/task']!,
          settings: settings
      );
    default:
      return CupertinoPageRoute(
      builder: routes['/init']!,
      settings: settings
    );
  }
}

Map<String, Widget Function(BuildContext)> routes = {
  '/init':(context) => const InitScreen(),
  '/auth':(context) => const AuthScreen(),
  '/home-only':(context) => const HomeScreen(),
  '/home':(context) => Navigation(),
  '/my-tasks':(context) => const TasksScreen(),
  '/image':(context){
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String hero = args['hero'];
    Widget image = args['image'];
    return ImageScreen(heroTag: hero, image: image);
  },
  '/image-with-task':(context){
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String hero = args['hero'];
    Widget image = args['image'];
    Task task = args['task'];
    return ImageWithTaskScreen(heroTag: hero, image: image, task: task);
  },
  '/group-tasks':(context){
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var group = args['group'] as Group;
    return TasksScreen(group: group);
  },
  '/group':(context){
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var group = args['group'] as Group;
    return GroupScreen(group: group);
  },
  '/search':(context) => const SearchScreen(),
  '/task':(context){
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var task = args['task'] as Task;
    return TaskScreen(task: task);
  }
};

String initialRoute = '/init';