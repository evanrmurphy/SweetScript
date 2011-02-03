t = true
nil = null

acons = (x) ->
  if (x and (typeof x is 'object') and
            (x.constructor is Array)) then t else nil

atom = (x) ->
  if acons(x) then nil else t

car = (xs) -> xs[0]
cdr = (xs) -> xs[1]

cons = (a, d) -> [a, d]

caar = (xs) -> car(car(xs))
cadr = (xs) -> car(cdr(xs))
cdar = (xs) -> cdr(car(xs))
cddr = (xs) -> cdr(cdr(xs))

caaar = (xs) -> car(car(car(xs)))
caadr = (xs) -> car(car(cdr(xs)))
cadar = (xs) -> car(cdr(car(xs)))
caddr = (xs) -> car(cdr(cdr(xs)))
cdaar = (xs) -> cdr(car(car(xs)))
cdadr = (xs) -> cdr(car(cdr(xs)))
cddar = (xs) -> cdr(cdr(car(xs)))
cdddr = (xs) -> cdr(cdr(cdr(xs)))

len = (xs) ->
  if xs is nil then 0 else 1 + len(cdr(xs))

copylist = (xs) ->
  if xs.length == 0 then nil else cons car(xs), copylist(xs[1..])

list = (args...) -> copylist(args)

lookup1 = (name, vars, vals, env) ->
  if vars is nil
    lookup name, cdr(env)
  else if name is car(vars)
    vals
  else
    lookup1 name, cdr(vars), cdr(vals), env

lookup = (name, env) ->
  if env is nil
    nil
  else
    lookup1 name, caar(env), cdar(env), env

value1 = (name, slot) ->
  if slot is nil then nil else car(slot)

value = (name, env) ->
  value1 name, lookup(name, env)

bind = (vars, args, env) ->
  if atom(vars)
    cons(cons(list(vars), list(args)), env)
  else
    cons(cons(vars, args), env)
