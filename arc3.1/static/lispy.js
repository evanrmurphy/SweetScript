(function() {
  var Env, Eval, Symbol, globalEnv, isa, list, typeOf;
  var __slice = Array.prototype.slice;
  typeOf = function(value) {
    var s;
    s = typeof value;
    if (s === 'object') {
      if (value) {
        if (value instanceof Array) {
          s = 'array';
        } else {
          s = 'null';
        }
      }
    }
    return s;
  };
  isa = function(x, y) {
    return typeOf(x) === y;
  };
  Symbol = "string";
  list = "array";
  Env = function() {
    function Env(parms, args, outer) {
      if (parms == null) {
        parms = [];
      }
      if (args == null) {
        args = [];
      }
      if (outer == null) {
        outer = null;
      }
      _(_.zip(parms, args)).each(function(keyVal) {
        var key, val;
        key = keyVal[0], val = keyVal[1];
        return this[key] = val;
      });
      this.outer = outer;
    }
    Env.prototype.find = function(Var) {
      if (Var in this) {
        return this;
      } else {
        return this.outer.find(Var);
      }
    };
    return Env;
  }();
  globalEnv = new Env;
  Eval = function(x, env) {
    var Var, alt, conseq, exp, exps, proc, test, val, vars, _, _i, _j, _len, _len2, _ref, _results;
    if (env == null) {
      env = globalEnv;
    }
    if (isa(x, Symbol)) {
      return env.find(x)[x];
    } else if (isa(x, list)) {
      return x;
    } else if (x[0] === 'quote') {
      _ = x[0], exp = x[1];
      return exp;
    } else if (x[0] === 'if') {
      _ = x[0], test = x[1], conseq = x[2], alt = x[3];
      return Eval((Eval(test, env) ? conseq : alt), env);
    } else if (x[0] === 'set!') {
      _ = x[0], Var = x[1], exp = x[2];
      return env.find(Var)[Var] = Eval(exp, env);
    } else if (x[0] === 'define') {
      _ = x[0], Var = x[1], exp = x[2];
      return env[Var] = Eval(exp, env);
    } else if (x[0] === 'lambda') {
      _ = x[0], vars = x[1], exp = x[2];
      return function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return Eval(exp, Env(vars, args, env));
      };
    } else if (x[0] === 'begin') {
      _ref = x.slice(1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        exp = _ref[_i];
        val = Eval(exp, env);
      }
      return val;
    } else {
      exps = (function() {
        _results = [];
        for (_j = 0, _len2 = x.length; _j < _len2; _j++) {
          exp = x[_j];
          _results.push(Eval(exp, env));
        }
        return _results;
      }());
      proc = exps.shift();
      return proc(exps);
    }
  };
}).call(this);
