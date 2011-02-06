var X, acons, apply, arraylist, atom, bind, caaaar, caaadr, caaar, caadar, caaddr, caadr, caar, cadaar, cadadr, cadar, caddar, cadddr, caddr, cadr, car, cdaaar, cdaadr, cdaar, cdadar, cdaddr, cdadr, cdar, cddaar, cddadr, cddar, cdddar, cddddr, cdddr, cddr, cdr, cons, ev, ev1, evassign, evlist, evproc, globalEnv, isarray, isfexpr, isfn, len, list, lookup, lookup1, nil, rarraylist, rarraylistDot, rarraylistNonDot, read, t, test, tokenize, tokensrarray, tostr, value, value1;
var __slice = Array.prototype.slice;
test = function(name, x, expected) {
  if (!_(x).isEqual(expected)) {
    return console.log("" + name + " test failed");
  }
};
t = 't';
nil = 'nil';
isarray = function(x) {
  if (x && (typeof x === 'object') && (x.constructor === Array)) {
    return t;
  } else {
    return nil;
  }
};
acons = isarray;
atom = function(x) {
  if (acons(x) !== nil) {
    return nil;
  } else {
    return t;
  }
};
cons = function(a, d) {
  return [a, d];
};
test('cons #1', cons(1, nil), [1, nil]);
car = function(xs) {
  return xs[0];
};
test('car #1', car(cons(1, nil)), 1);
cdr = function(xs) {
  return xs[1];
};
test('cdr #1', cdr(cons(1, nil)), nil);
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
test('len #1', len(nil), 0);
test('len #2', len(cons(1, nil)), 1);
test('len #3', len(cons(1, cons(2, nil))), 2);
arraylist = function(a) {
  if (a.length === 0) {
    return nil;
  } else if (a.length > 2 && a[1] === '.') {
    return cons(a[0], a[2]);
  } else {
    return cons(a[0], arraylist(a.slice(1)));
  }
};
test('arraylist #1', arraylist([]), nil);
test('arraylist #2', arraylist([1]), cons(1, nil));
test('arraylist #3', arraylist([1, 2]), cons(1, cons(2, nil)));
test('arraylist #4', arraylist([1, '.', 2]), cons(1, 2));
list = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return arraylist(args);
};
test('list #1', list(), nil);
test('list #2', list(1), cons(1, nil));
test('list #3', list(1, 2), cons(1, cons(2, nil)));
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
  if (atom(vars) !== nil) {
    return cons(cons(list(vars), list(args)), env);
  } else {
    return cons(cons(vars, args), env);
  }
};
test('bind #1', bind(list('x'), list(1), nil), list(cons(list('x'), list(1))));
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
  if (car(f) === '#<procedure>') {
    return apply(f, evlist(args, env));
  } else if (car(f) === '#<fexpr>') {
    return apply(f, args);
  }
};
globalEnv = nil;
evassign = function(place, val, env) {
  env = globalEnv = bind(place, ev(val, env), env);
  return ev(val, env);
};
ev1 = function(s, env) {
  switch (car(s)) {
    case 'vau':
      return list('#<fexpr>', cadr(s), caddr(s), env);
    case 'fn':
      return list('#<procedure>', cadr(s), caddr(s), env);
    case 'assign':
      return evassign(cadr(s), caddr(s), env);
    case 'eval':
      return ev(cadr(s), env);
    case 'cons':
      return cons(ev(cadr(s), env), ev(caddr(s), env));
    case 'car':
      return car(ev(cadr(s), env));
    case 'cdr':
      return cdr(ev(cadr(s), env));
    default:
      return evproc(ev(car(s), env), cdr(s), env);
  }
};
ev = function(s, env) {
  if (env == null) {
    env = globalEnv;
  }
  if (atom(s) !== nil) {
    return value(s, env);
  } else {
    return ev1(s, env);
  }
};
rarraylistDot = function(a) {
  if (isarray(a[0]) !== nil) {
    return cons(rarraylist(a[0]), rarraylist(a[2]));
  } else {
    return cons(a[0], rarraylist(a[2]));
  }
};
rarraylistNonDot = function(a) {
  if (isarray(a[0]) !== nil) {
    return cons(rarraylist(a[0]), rarraylist(a.slice(1)));
  } else {
    return cons(a[0], rarraylist(a.slice(1)));
  }
};
rarraylist = function(a) {
  if (atom(a) !== nil) {
    return a;
  } else if (a.length === 0) {
    return nil;
  } else if (a.length === 3 && a[1] === '.') {
    return rarraylistDot(a);
  } else {
    return rarraylistNonDot(a);
  }
};
test('rarraylist #1', rarraylist([]), nil);
test('rarraylist #2', rarraylist([1]), list(1));
test('rarraylist #3', rarraylist([1, 2, 3]), list(1, 2, 3));
test('rarraylist #4', rarraylist([1, [2, 3], 4]), list(1, list(2, 3), 4));
test('rarraylist #5', rarraylist([1, [2, '.', 3], 4]), list(1, cons(2, 3), 4));
test('rarraylist #6', rarraylist([1, '.', [2, '.', 3]]), cons(1, cons(2, 3)));
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
  return rarraylist(tokensrarray(tokenize(s)));
};
test('read #1', read('t'), 't');
test('read #2', read('nil'), 'nil');
test('read #3', read('(1)'), list('1'));
test('read #4', read('(foo bar)'), list('foo', 'bar'));
test('read #5', read('(foo . bar)'), cons('foo', 'bar'));
test('read #6', read('(foo . (bar . baz))'), cons('foo', cons('bar', 'baz')));
test('read #7', read('(foo . (bar . nil))'), cons('foo', cons('bar', nil)));
isfn = function(x) {
  if (acons(x) !== nil && car(x) === '#<procedure>') {
    return t;
  } else {
    return nil;
  }
};
isfexpr = function(x) {
  if (acons(x) !== nil && (car(x) === '#<fexpr>')) {
    return t;
  } else {
    return nil;
  }
};
tostr = function(s) {
  if (atom(s) !== nil) {
    if (s === nil) {
      return 'nil';
    } else {
      return s;
    }
  } else if (isfn(s) !== nil) {
    return '#<procedure>';
  } else if (isfexpr(s) !== nil) {
    return '#<fexpr>';
  } else {
    return "(" + (tostr(car(s))) + " . " + (tostr(cdr(s))) + ")";
  }
};
test('tostr #1', tostr(nil), 'nil');
test('tostr #2', tostr(list(1)), '(1 . nil)');
test('tostr #3', tostr(list(1, 2)), '(1 . (2 . nil))');
X = function(s) {
  return tostr(ev(read(s)));
};
test('vau #1', X('((vau () nil))'), 'nil');
test('vau #2', X('((vau (x) x) y)'), 'y');
X('(assign quote (vau (x) x))');
test('quote #1', X('(quote a)'), 'a');
test('quote #2', X('(quote (a b))'), tostr(list('a', 'b')));
test('fn #1', X('((fn () nil))'), 'nil');
test('fn #2', X('((fn (x) x) (quote a))'), 'a');
test('fn #3', X('((fn (x y) (cons x y)) (quote a) (quote b)))'), '(a . b)');
X('(assign t (quote t))');
X('(assign nil (quote nil))');
test('t #1', X('t'), 't');
test('nil #1', X('nil'), 'nil');
X('(assign caar (fn (xs) (car (car xs))))');
X('(assign cadr (fn (xs) (car (cdr xs))))');
X('(assign cdar (fn (xs) (cdr (car xs))))');
X('(assign cddr (fn (xs) (cdr (cdr xs))))');