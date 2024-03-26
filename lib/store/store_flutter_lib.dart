import 'dart:math';
import 'package:notify/store/store_lib.dart';
import 'package:flutter/material.dart';

class StoreConnect{
  StoreConnect({
    required this.key,
    required this.store
  });
  String key;
  Collector store;
}

class Reactive<T> with ChangeNotifier{
  Reactive(T? value, [ StoreConnect? storeConnection]){
    if(storeConnection==null){
      var gkey = _generateKey();
      if((value) is! T&&value!=null) throw Exception('Value type is not matches');
      _store = Collector({gkey:value});
      _key = gkey;
    }else{
      _store = storeConnection.store;
      _key = storeConnection.key;
      _store.set(_key, _store.get(_key)??value, false);
    }
  }
  String _key = '';
  late Collector _store;
  int _watchIndex = -1;

  T get value => _store.get(_key);
  set value(T value){
    if(value!=null){
      _store.set(_key, value);
      notifyListeners();
    }else{
      throw Exception("Value is null!");
    }
  }
  void watch(Function(T newValue) onUpdate){
    _watchIndex = _store.watch(_key, onUpdate);
  }
  void dispose(){
    super.dispose();
    if(_watchIndex!=-1) _store.unSeeAt(_key, _watchIndex);
  }

  void disposeAt(int index){
    super.dispose();
    _store.unSeeAt(_key, index);
  }

  String _generateKey(){
    var key = [
      for (var i = 0; i<10; i++)
        Random().nextInt(9)
    ].join('');
    return key;
  }

  factory Reactive.withStore(StoreConnect store, [T? optionalValue])=>Reactive(optionalValue, store);
}

class ReactiveBuilder<React extends Reactive> extends StatefulWidget{
  ReactiveBuilder({
    super.key,
    required this.reactive,
    required this.builder,
  });
  React reactive;
  Widget Function(BuildContext context) builder;

  @override
  State<StatefulWidget> createState() => _StateReactiveBuilder();
}

class _StateReactiveBuilder extends State<ReactiveBuilder>{

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.reactive,
        builder: (context, _){
          return widget.builder(context);
        }
    );
  }
}