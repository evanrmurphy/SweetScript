(function() {
  var Env, Eval, Symbol, ToString, addGlobals, atom, globalEnv, isa, list, parse, read, readFrom, repl, tokenize, typeOf;
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
      var _ref;
      if (Var in this) {
        return this;
      } else {
        return (_ref = this.outer) != null ? _ref.find(Var) : void 0;
      }
    };
    return Env;
  }();
  addGlobals = function(env) {
    _(env).extend({
      '+': function(x, y) {
        return x + y;
      },
      'cons': function(x, y) {
        return [x].concat(y);
      },
      'car': function(xs) {
        return xs[0];
      },
      'cdr': function(xs) {
        return xs.slice(1);
      }
    });
    return env;
  };
  globalEnv = addGlobals(new Env);
  Eval = function(x, env) {
    var Var, alt, conseq, exp, exps, proc, test, val, vars, _, _i, _j, _len, _len2, _ref, _results;
    if (env == null) {
      env = globalEnv;
    }
    console.log('in Eval');
    console.log('x is', x);
    console.log('env is', env);
    if (isa(x, Symbol)) {
      console.log('variable reference');
      return env.find(x)[x];
    } else if (!isa(x, list)) {
      console.log('constant literal');
      return x;
    } else if (x[0] === 'quote') {
      _ = x[0], exp = x[1];
      return exp;
    } else if (x[0] === 'if') {
      _ = x[0], test = x[1], conseq = x[2], alt = x[3];
      return Eval((Eval(test, env) ? conseq : alt), env);
    } else if (x[0] === '=') {
      console.log('(= var exp)');
      _ = x[0], Var = x[1], exp = x[2];
      if (env.find(Var)) {
        return env.find(Var)[Var] = Eval(exp, env);
      } else {
        return env[Var] = Eval(exp, env);
      }
    } else if (x[0] === 'fn') {
      _ = x[0], vars = x[1], exp = x[2];
      return function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return Eval(exp, Env(vars, args, env));
      };
    } else if (x[0] === 'do') {
      _ref = x.slice(1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        exp = _ref[_i];
        val = Eval(exp, env);
      }
      return val;
    } else {
      console.log('(proc exp*)');
      exps = (function() {
        _results = [];
        for (_j = 0, _len2 = x.length; _j < _len2; _j++) {
          exp = x[_j];
          _results.push(Eval(exp, env));
        }
        return _results;
      }());
      proc = exps.shift();
      console.log('proc is', proc);
      console.log('exps is', exps);
      return proc.apply(proc, exps);
    }
  };
  read = function(s) {
    return readFrom(tokenize(s));
  };
  parse = read;
  tokenize = function(s) {
    return _(s.replace('(', ' ( ').replace(')', ' ) ').split(' ')).without('');
  };
  readFrom = function(tokens) {
    var L, token;
    if (tokens.length === 0) {
      alert('unexpected EOF while reading');
    }
    token = tokens.shift();
    if ('(' === token) {
      L = [];
      while (tokens[0] !== ')') {
        L.push(readFrom(tokens));
      }
      tokens.shift();
      return L;
    } else if (')' === token) {
      return alert('unexpected )');
    } else {
      return atom(token);
    }
  };
  atom = function(token) {
    if (token.match(/^\d+\.?$/)) {
      return parseInt(token);
    } else if (token.match(/^\d*\.\d+$/)) {
      return parseFloat(token);
    } else {
      return "" + token;
    }
  };
  ToString = function(exp) {
    if (isa(exp, list)) {
      return '(' + (_(exp).map(ToString)).join(' ') + ')';
    } else {
      return exp.toString();
    }
  };
  repl = function(p) {
    var input, val, _results;
    if (p == null) {
      p = 'sweet> ';
    }
    _results = [];
    while (input !== '(quit)') {
      input = prompt(p);
      val = Eval(parse(input));
      _results.push(alert(ToString(val)));
    }
    return _results;
  };
  window.repl = repl;
  window.read = read;
  window.parse = parse;
  window.tokenize = tokenize;
  window.ToString = ToString;
  window.atom = atom;
  window.Env = Env;
  window.globalEnv = globalEnv;
  window.Eval = Eval;
  repl();
}).call(this);
