var acons, apply, atom, bind, caaaar, caaadr, caaar, caadar, caaddr, caadr, caar, cadaar, cadadr, cadar, caddar, cadddr, caddr, cadr, car, cdaaar, cdaadr, cdaar, cdadar, cdaddr, cdadr, cdar, cddaar, cddadr, cddar, cdddar, cddddr, cdddr, cddr, cdr, cons, copylist, ev, ev1, evlist, evproc, len, list, lookup, lookup1, nil, t, value, value1;
var __slice = Array.prototype.slice;
t = true;
nil = null;
acons = function(x) {
  if (x && (typeof x === 'object') && (x.constructor === Array)) {
    return t;
  } else {
    return nil;
  }
};
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
copylist = function(xs) {
  if (xs.length === 0) {
    return nil;
  } else {
    return cons(car(xs), copylist(xs.slice(1)));
  }
};
list = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return copylist(args);
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
  }
};
ev1 = function(exp, env) {
  switch (car(exp)) {
    case 'fn':
      return list('&procedure', cadr(exp), caddr(exp), env);
    case 'car':
      return car(ev(cadr(exp), env));
    case 'cdr':
      return cdr(ev(cadr(exp), env));
    case 'cons':
      return cons(ev(cadr(exp), env), ev(caddr(exp)));
    case 'quote':
      return cadr(exp);
    default:
      return evproc(ev(car(exp), env), cdr(exp), env);
  }
};
ev = function(exp, env) {
  if (atom(exp)) {
    return value(exp, env);
  } else {
    return ev1(exp, env);
  }
};