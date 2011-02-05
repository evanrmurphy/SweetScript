var X, acons, apply, arraylist, atom, bind, caaaar, caaadr, caaar, caadar, caaddr, caadr, caar, cadaar, cadadr, cadar, caddar, cadddr, caddr, cadr, car, cdaaar, cdaadr, cdaar, cdadar, cdaddr, cdadr, cdar, cddaar, cddadr, cddar, cdddar, cddddr, cdddr, cddr, cdr, cons, ev, ev1, evassign, evlist, evproc, globalEnv, isArray, len, list, lookup, lookup1, nil, rarraylist, read, t, tokenize, tokensrarray, tostr, value, value1;
var __slice = Array.prototype.slice;
t = true;
nil = null;
isArray = function(x) {
  if (x && (typeof x === 'object') && (x.constructor === Array)) {
    return t;
  } else {
    return nil;
  }
};
acons = isArray;
atom = function(x) {
  if (acons(x)) {
    return nil;
  } else {
    return t;
  }
};
car = function(xs) {
  return xs[0];
};
cdr = function(xs) {
  return xs[1];
};
cons = function(a, d) {
  return [a, d];
};
caar = function(xs) {
  return car(car(xs));
};
cadr = function(xs) {
  return car(cdr(xs));
};
cdar = function(xs) {
  return cdr(car(xs));
};
cddr = function(xs) {
  return cdr(cdr(xs));
};
caaar = function(xs) {
  return car(car(car(xs)));
};
caadr = function(xs) {
  return car(car(cdr(xs)));
};
cadar = function(xs) {
  return car(cdr(car(xs)));
};
caddr = function(xs) {
  return car(cdr(cdr(xs)));
};
cdaar = function(xs) {
  return cdr(car(car(xs)));
};
cdadr = function(xs) {
  return cdr(car(cdr(xs)));
};
cddar = function(xs) {
  return cdr(cdr(car(xs)));
};
cdddr = function(xs) {
  return cdr(cdr(cdr(xs)));
};
caaaar = function(xs) {
  return car(car(car(car(xs))));
};
caaadr = function(xs) {
  return car(car(car(cdr(xs))));
};
caadar = function(xs) {
  return car(car(cdr(car(xs))));
};
caaddr = function(xs) {
  return car(car(cdr(cdr(xs))));
};
cadaar = function(xs) {
  return car(cdr(car(car(xs))));
};
cadadr = function(xs) {
  return car(cdr(car(cdr(xs))));
};
caddar = function(xs) {
  return car(cdr(cdr(car(xs))));
};
cadddr = function(xs) {
  return car(cdr(cdr(cdr(xs))));
};
cdaaar = function(xs) {
  return cdr(car(car(car(xs))));
};
cdaadr = function(xs) {
  return cdr(car(car(cdr(xs))));
};
cdadar = function(xs) {
  return cdr(car(cdr(car(xs))));
};
cdaddr = function(xs) {
  return cdr(car(cdr(cdr(xs))));
};
cddaar = function(xs) {
  return cdr(cdr(car(car(xs))));
};
cddadr = function(xs) {
  return cdr(cdr(car(cdr(xs))));
};
cdddar = function(xs) {
  return cdr(cdr(cdr(car(xs))));
};
cddddr = function(xs) {
  return cdr(cdr(cdr(cdr(xs))));
};
len = function(xs) {
  if (xs === nil) {
    return 0;
  } else {
    return 1 + len(cdr(xs));
  }
};
arraylist = function(a) {
  if (a.length === 0) {
    return nil;
  } else {
    return cons(a[0], arraylist(a.slice(1)));
  }
};
list = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return arraylist(args);
};
lookup1 = function(name, vars, vals, env) {
  if (vars === nil) {
    return lookup(name, cdr(env));
  } else if (name === car(vars)) {
    return vals;
  } else {
    return lookup1(name, cdr(vars), cdr(vals), env);
  }
};
lookup = function(name, env) {
  if (env === nil) {
    return nil;
  } else {
    return lookup1(name, caar(env), cdar(env), env);
  }
};
value1 = function(name, slot) {
  if (slot === nil) {
    return nil;
  } else {
    return car(slot);
  }
};
value = function(name, env) {
  return value1(name, lookup(name, env));
};
bind = function(vars, args, env) {
  if (atom(vars)) {
    return cons(cons(list(vars), list(args)), env);
  } else {
    return cons(cons(vars, args), env);
  }
};
apply = function(f, args) {
  return ev(caddr(f), bind(cadr(f), args, cadddr(f)));
};
evlist = function(xs, env) {
  if (xs === nil) {
    return nil;
  } else {
    return cons(ev(car(xs), env), evlist(cdr(xs), env));
  }
};
evproc = function(f, args, env) {
  if (car(f) === '&procedure') {
    return apply(f, evlist(args, env));
  } else if (car(f) === '&fexpr') {
    return apply(f, args);
  }
};
globalEnv = nil;
evassign = function(place, val, env) {
  env = globalEnv = bind(place, ev(val, env), env);
  return ev(val, env);
};
ev1 = function(exp, env) {
  switch (car(exp)) {
    case 'vau':
      return list('&fexpr', cadr(exp), caddr(exp), env);
    case 'fn':
      return list('&procedure', cadr(exp), caddr(exp), env);
    case 'assign':
      return evassign(cadr(exp), caddr(exp), env);
    case 'eval':
      return ev(cadr(exp), env);
    case 'env':
      return env;
    case 'car':
      return car(ev(cadr(exp), env));
    case 'cdr':
      return cdr(ev(cadr(exp), env));
    case 'cons':
      return cons(ev(cadr(exp), env), ev(caddr(exp)));
    default:
      return evproc(ev(car(exp), env), cdr(exp), env);
  }
};
ev = function(exp, env) {
  if (env == null) {
    env = globalEnv;
  }
  if (atom(exp)) {
    return value(exp, env);
  } else {
    return ev1(exp, env);
  }
};
rarraylist = function(a) {
  if (a.length === 0) {
    return nil;
  } else if (isArray(a[0])) {
    return cons(rarraylist(a[0]), rarraylist(a.slice(1)));
  } else {
    return cons(a[0], rarraylist(a.slice(1)));
  }
};
tokensrarray = function(ts) {
  var acc, tok;
  tok = ts.shift();
  if (tok === '(') {
    acc = [];
    while (ts[0] !== ')') {
      acc.push(tokensrarray(ts));
    }
    ts.shift();
    return acc;
  } else {
    return tok;
  }
};
tokenize = function(s) {
  var spaced;
  spaced = s.replace(/\(/g, ' ( ').replace(/\)/g, ' ) ').split(' ');
  return _(spaced).without('');
};
read = function(s) {
  var acc;
  acc = tokensrarray(tokenize(s));
  if (isArray(acc)) {
    return rarraylist(acc);
  } else {
    return acc;
  }
};
tostr = function(s) {
  if (atom(s)) {
    if (s === nil) {
      return 'nil';
    } else {
      return s;
    }
  } else {
    return "(" + (tostr(car(s))) + " . " + (tostr(cdr(s))) + ")";
  }
};
X = function(s) {
  return tostr(ev(read(s)));
};
X('(assign quote (vau (x) x))');
X('(assign t (quote t))');
X('(assign nil (quote nil))');