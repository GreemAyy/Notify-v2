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
  Reactive(T? value, [StoreConnect? storeConnection, bool nullable = false]){
    _nullable = nullable;
    if(storeConnection==null){
      var gkey = _generateKey();
      if((value) is! T&&value!=null) throw Exception('Value type is not matches');
      _store = Collector({gkey:value}, strongTyped: !nullable);
      _key = gkey;
    }else{
      _store = storeConnection.store;
      _store.strongTyped = !nullable;
      _key = storeConnection.key;
      _store.set(_key, _store.get(_key)??value, false);
    }
  }
  String _key = '';
  bool _nullable = false;
  late Collector _store;
  List<int> _watchIndex = [];

  Reactive<T> get nullable{
    _store.strongTyped = false;
    _nullable = true;
    return this;
  }

  T get value => _store.get(_key);
  set value(T value){
    if(_nullable||value!=null){
      _store.set(_key, value);
      notifyListeners();
    }else{
      throw Exception("Value is null!");
    }
  }
  void Function() watch(void Function(T newValue) onUpdate){
    final index = _store.watch(_key, onUpdate);
    _watchIndex.add(index);
    return () => _store.unSeeAt(_key, index);
  }
  void dispose(){
    super.dispose();
    if(_watchIndex.isNotEmpty){
      _store.destroy(_key);
    }
  }

  String _generateKey(){
    var key = [
      for (var i = 0; i<10; i++)
        Random().nextInt(9)
    ].join('');
    return key;
  }

  ReactiveBuilder toBuilder(Widget Function(BuildContext context) builder){
    return ReactiveBuilder(reactive: this, builder: builder);
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