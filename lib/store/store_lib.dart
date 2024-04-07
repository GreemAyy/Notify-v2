class _EventEmitter {
    Map<String,List<Function?>> events = {};

    int getEventsCount(String key){
      return events[key]?.length??0;
    }

    void on(String eventName, void Function() callback){
      var event = events[eventName];
      if(event==null){
         events[eventName]=[];
      }
      events[eventName]!.add(callback);
    }
    void emit(String eventName, [dynamic value]){
      var callbacks = events[eventName];
      if(callbacks != null){
        for (var call in callbacks) {
          if(call!=null){
            call();
          }
        }
      }
    }
    void remove(String eventName){
      try{
        events.remove(eventName);
      }catch(e){
        rethrow;
      }
    }

    void removeAt(String eventName, int index){
      try{
        if(events[eventName]!.length==1){
          events[eventName]!.clear();
        }else{
          events[eventName]![index] = null;
        }
        var isEveryNull = events[eventName]!.where((element) => element!=null).isEmpty;
        if(isEveryNull){
          events[eventName]!.clear();
        }
      }catch(e){
        rethrow;
      }
    }
}

class Collector{
    Collector(this._states, {
      this.strongTyped = true,
      this.debug = false
    });
    Map<String, dynamic> _states;
    ({String key, dynamic data}) _lastUpdate = (key: '', data: null);
    var _logs = <String>[];
    bool debug;
    bool strongTyped;
    final Map<String, dynamic> _localHolder = {};
    late final _emitter = _EventEmitter();

    Map<String, dynamic> get ${
      return _states;
    }

    bool isNull(String key) => _states[key]==null;
    bool isNotNull(String key) => !isNull(key);

    Collector get unType{
      strongTyped=false;
      return this;
    }

    Collector get onType{
      strongTyped=true;
      return this;
    }

    void set(String key, dynamic value, [bool shouldUpdate = true]){
      var valueAt = _states[key];
      if(valueAt == value) return;
      if(valueAt!=null&&!identical(value.runtimeType, valueAt.runtimeType)&&strongTyped){
        throw Exception('New value type at key :$key is not matches to setted value');
      }
      if(debug){
        var _ = 'set: $key value: $value';
        print(_);
        _logs.add(_);
      }
      _states[key] = value;
      if(shouldUpdate){
        _emitter.emit(key);
      }
    }

    void waitSet(String key, dynamic value, [bool shouldUpdate = true]){
      Future.microtask(() => set(key, value, shouldUpdate));
    }

    void mapMultiSet(Map<String, dynamic> value){
      value.forEach((key, value) {
        var valueAt = _states[key];
        if(valueAt!=null&&!identical(value.runtimeType, valueAt.runtimeType)&&strongTyped){
          throw Exception('New value type at key :$key is not matches to setted value');
        }
        if(debug) {
          var _ = 'set: $key value: $value';
          print(_);
          _logs.add(_);
        }
        if(value is Map<String, dynamic> && value["--update"] != null){
            _states[key] = value["--update"];
        }else{
          _states[key] = value;
          _emitter.emit(key);
        }
      });
    }

    void multiSet(List<String> keys, List<dynamic> values, [List<bool> shouldUpdate = const []]){
        for(int i = 0; i < keys.length; i++){
          var key = keys[i];
          var value = values[i];
          var valueAt = _states[key];
          if(valueAt!=null&&!identical(value.runtimeType, valueAt.runtimeType)&&strongTyped){
            throw Exception('New value type at key :$key is not matches to setted value');
          }
          if(debug){
            var _ = 'set: $key value: $value';
            print(_);
            _logs.add(_);
          }
          _states[key] = value;
          if(keys.length == shouldUpdate.length && shouldUpdate[i]){
              _emitter.emit(key);
          }else if(shouldUpdate.length == 1 && shouldUpdate[0]){
            _emitter.emit(key);
          }else if(shouldUpdate.length<keys.length && shouldUpdate.isNotEmpty){
            if(i > shouldUpdate.length -1 && shouldUpdate.last){
              _emitter.emit(key);
            }else if(shouldUpdate[i]){
              _emitter.emit(key);
            }
          }else{
            _emitter.emit(key);
          }
        }
    }

    void update(String key){
      if(debug) {
        var _ = 'update: $key events -> ${_emitter.events[key]}';
        print(_);
        _logs.add(_);
      }
      _emitter.emit(key);
    }

    void updateWithData(String key, dynamic data){
      if(debug){
        var _ = 'update: $key value: $data events -> ${_emitter.events[key]}';
        print(_);
        _logs.add(_);
      }
      _localHolder[key] = data;
      _emitter.emit(key);
    }

    int watch<CallbackType>(String key, void Function(CallbackType data) callback){
      if(debug){
        var _ = 'watch_created: $key watchers_count: ${_emitter.getEventsCount(key)+1}';
        print(_);
        _logs.add(_);
      }
      _emitter.on(key, (){
        if(debug){
          var _ = 'watch_created: $key watchers_count: ${_emitter.getEventsCount(key)+1}';
          print(_);
          _logs.add(_);
        }
        callback(_states[key]??_localHolder[key]);
        _lastUpdate = (key: key, data: _states[key]??_localHolder[key]);
        _emitter.emit('__ANY__WATCH__');
      });
      if(_localHolder[key]!=null){
        _localHolder.remove(key);
      }
      return _emitter.getEventsCount(key)-1;
    }

    void anyWatch(void Function(String key, dynamic data) callback){
      _emitter.on('__ANY__WATCH__', () {
        callback(_lastUpdate.key, _lastUpdate.data);
      });
    }

    T? get<T>(String key) => _states[key];

    void remove(String key){
      try{
        if(debug){
          var _ = 'remove: $key';
          print(_);
          _logs.add(_);
        }
        _states.remove(key);
      }catch(e){
        rethrow;
      }
    }

    void destroy(String key){
      try{
        if(debug){
          var _ = 'remove: $key';
          print(_);
          _logs.add(_);
        }
        _states.remove(key);
        _emitter.remove(key);
      }catch(e){
        rethrow;
      }
    }

    void unSee(String key){
      if(debug){
        var _ = 'remove: $key';
        print(_);
        _logs.add(_);
      }
      _emitter.remove(key);
    }
    void unSeeAt(String key, int index){
      if(debug){
        var _ = 'remove: $key at: $index';
        print(_);
        _logs.add(_);
      }
      _emitter.removeAt(key, index);
    }
}