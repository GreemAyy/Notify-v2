import 'package:notify/store/store_lib.dart';
import 'package:flutter/material.dart';
import '../custom_classes/group.dart';

var store = Collector({
   'theme_mode':ThemeMode.system,
   'locale': const Locale('en'),
   'id':null,
   'hash':null,
   'date':DateTime.now(),
   'group':0,
   'groups':<Group>[],
   'task_is_loading':false,
}, logMessages: true);
