// t, nil

t = true;
nil = null;

// is, no

is = function(x, y) {
  return (x === y) ? t : nil;
}

no = function(x) {
  return is(x, nil) ? t : nil;
}

// acons, atom

acons = function(x) {
  return (x && is(typeof x, 'object')
            && is(x.constructor, Array)) ? t : nil;
}

atom = function(x) {
  return acons(x) ? nil : t;
}

// car, cdr, cons

car = function(xs) {
  return xs[0];
}

cdr = function(xs) {
  return xs[1];
}

cons = function(a, d) {
  return [a, d];
}

// utils

caar = function(xs) { return car(car(xs)); }
cadr = function(xs) { return car(cdr(xs)); }
cdar = function(xs) { return cdr(car(xs)); }
cddr = function(xs) { return cdr(cdr(xs)); }

caaar = function(xs) { return car(car(car(xs))); }
caadr = function(xs) { return car(car(cdr(xs))); }
cadar = function(xs) { return car(cdr(car(xs))); }
caddr = function(xs) { return car(cdr(cdr(xs))); }
cdaar = function(xs) { return cdr(car(car(xs))); }
cdadr = function(xs) { return cdr(car(cdr(xs))); }
cddar = function(xs) { return cdr(cdr(car(xs))); }
cdddr = function(xs) { return cdr(cdr(cdr(xs))); }

len = function(xs) {
  return no(xs)
    ? 0
    : 1 + len(cdr(xs));
}

// needs to work for variable number of args
list = function(x) {
  return cons(x, nil);
}

// environments

lookup1 = function(name, vars, vals, env) {
  return no(vars)
    ? lookup(name, cdr(env))
    : (is(name, car(vars))
       ? vals
       : lookup1(name, cdr(vars), cdr(vals), env));
}

lookup = function(name, env) {
  return no(env)
    ? nil
    : lookup1(name, caar(env), cdar(env), env);
}

value1 = function(name, slot) {
  return no(slot)
    ? nil
    : car(slot);
}

value = function(name, env) {
  return value1(name, lookup(name, env));
}

bind = function(vars, args, env) {
  return atom(vars)
    ? cons(cons(list(vars), list(args)), env)
    : cons(cons(vars, args), env);
}

vars = cons('t', cons('nil', nil))
args = cons(t,   cons(nil,   nil))
env = bind(vars, args, nil)

exp = cons('car', cons(cons('a', nil), nil))

// eval ("ev", since eval is reserved in javascript)

ev = function(exp, env) {
  return atom(exp)             ? value(exp, env)
       : (is(car(exp), 'car')  ? car(ev(cadr(exp), env))
       : (is(car(exp), 'cdr')  ? cdr(ev(cadr(exp), env))
       : (is(car(exp), 'cons') ? cons(ev(cadr(exp), env),
                                      ev(caddr(exp), env))
       : nil)));
}
