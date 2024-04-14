// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Auth`
  String get auth {
    return Intl.message(
      'Auth',
      name: 'auth',
      desc: '',
      args: [],
    );
  }

  /// `Write code`
  String get auth_code {
    return Intl.message(
      'Write code',
      name: 'auth_code',
      desc: '',
      args: [],
    );
  }

  /// `Wrong email or password!`
  String get snack_bar {
    return Intl.message(
      'Wrong email or password!',
      name: 'snack_bar',
      desc: '',
      args: [],
    );
  }

  /// `Log`
  String get log_btn {
    return Intl.message(
      'Log',
      name: 'log_btn',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get home_header {
    return Intl.message(
      'Groups',
      name: 'home_header',
      desc: '',
      args: [],
    );
  }

  /// `My tasks`
  String get my_tasks_text {
    return Intl.message(
      'My tasks',
      name: 'my_tasks_text',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get home_task_header {
    return Intl.message(
      'Tasks',
      name: 'home_task_header',
      desc: '',
      args: [],
    );
  }

  /// `Task`
  String get task {
    return Intl.message(
      'Task',
      name: 'task',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get avatar {
    return Intl.message(
      'Avatar',
      name: 'avatar',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get photo {
    return Intl.message(
      'Photo',
      name: 'photo',
      desc: '',
      args: [],
    );
  }

  /// `Write name`
  String get hint_name {
    return Intl.message(
      'Write name',
      name: 'hint_name',
      desc: '',
      args: [],
    );
  }

  /// `Pick photo`
  String get hint_photo {
    return Intl.message(
      'Pick photo',
      name: 'hint_photo',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Create group`
  String get create_group {
    return Intl.message(
      'Create group',
      name: 'create_group',
      desc: '',
      args: [],
    );
  }

  /// `Group length less then 1`
  String get group_name_error {
    return Intl.message(
      'Group length less then 1',
      name: 'group_name_error',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get empty {
    return Intl.message(
      'Empty',
      name: 'empty',
      desc: '',
      args: [],
    );
  }

  /// `Write`
  String get write {
    return Intl.message(
      'Write',
      name: 'write',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get task_title {
    return Intl.message(
      'Title',
      name: 'task_title',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get task_description {
    return Intl.message(
      'Description',
      name: 'task_description',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get task_date {
    return Intl.message(
      'Date',
      name: 'task_date',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get task_time {
    return Intl.message(
      'Time',
      name: 'task_time',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get task_from {
    return Intl.message(
      'From',
      name: 'task_from',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get task_to {
    return Intl.message(
      'To',
      name: 'task_to',
      desc: '',
      args: [],
    );
  }

  /// `Uncompleted`
  String get status_uncompleted {
    return Intl.message(
      'Uncompleted',
      name: 'status_uncompleted',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get status_completed {
    return Intl.message(
      'Completed',
      name: 'status_completed',
      desc: '',
      args: [],
    );
  }

  /// `No photo`
  String get no_photo {
    return Intl.message(
      'No photo',
      name: 'no_photo',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get btn_complete {
    return Intl.message(
      'Complete',
      name: 'btn_complete',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get btn_cancel {
    return Intl.message(
      'Cancel',
      name: 'btn_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get btn_delete {
    return Intl.message(
      'Delete',
      name: 'btn_delete',
      desc: '',
      args: [],
    );
  }

  /// `Edit task`
  String get edit_task {
    return Intl.message(
      'Edit task',
      name: 'edit_task',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Find`
  String get find {
    return Intl.message(
      'Find',
      name: 'find',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message(
      'Log out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system_theme {
    return Intl.message(
      'System',
      name: 'system_theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light_theme {
    return Intl.message(
      'Light',
      name: 'light_theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark_theme {
    return Intl.message(
      'Dark',
      name: 'dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message(
      'Message',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `Write message`
  String get write_message {
    return Intl.message(
      'Write message',
      name: 'write_message',
      desc: '',
      args: [],
    );
  }

  /// `Add image`
  String get add_image {
    return Intl.message(
      'Add image',
      name: 'add_image',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Already picked`
  String get already_picked {
    return Intl.message(
      'Already picked',
      name: 'already_picked',
      desc: '',
      args: [],
    );
  }

  /// `Max`
  String get max {
    return Intl.message(
      'Max',
      name: 'max',
      desc: '',
      args: [],
    );
  }

  /// `No access to gallery!`
  String get no_access_to_gallery {
    return Intl.message(
      'No access to gallery!',
      name: 'no_access_to_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Allow`
  String get allow {
    return Intl.message(
      'Allow',
      name: 'allow',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to chat. Please wait!`
  String get connecting_to_chat {
    return Intl.message(
      'Connecting to chat. Please wait!',
      name: 'connecting_to_chat',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Message deleted`
  String get message_deleted {
    return Intl.message(
      'Message deleted',
      name: 'message_deleted',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
