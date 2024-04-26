import 'package:notify/Navigation.dart';
import 'package:notify/custom_classes/group.dart';
import 'package:notify/custom_classes/task.dart';
import 'package:notify/screens/Auth.screen.dart';
import 'package:notify/screens/Chat.screen.dart';
import 'package:notify/screens/Group.screen.dart';
import 'package:notify/screens/Home.screen.dart';
import 'package:notify/screens/Image.screen.dart';
import 'package:notify/screens/Init.screen.dart';
import 'package:notify/screens/Search.screen.dart';
import 'package:notify/screens/Task.screen.dart';
import 'package:notify/screens/Tasks.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) =>
    (
      settings.name!.contains('/image')?
      MaterialPageRoute(
          builder: routes[settings.name]!,
          settings: settings
      )
      :
      CupertinoPageRoute(
          builder:  routes[settings.name]??routes['/init']!,
          settings: settings
      )
    );

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
  },
  '/chat':(context){
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var group = args['group'] as Group;
    return ChatScreen(group: group);
  }
};

String initialRoute = '/init';