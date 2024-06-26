import 'package:notify/store/collector.dart';
import 'package:flutter/material.dart';
import '../custom_classes/group.dart';

final store = Collector({
   'theme_mode':ThemeMode.system,
   'locale': const Locale('en'),
   'id':null,
   'hash':null,
   'date':DateTime.now(),
   'group':0,
   'groups':<Group>[],
   'task_is_loading':false,
   'on_chat':false
});