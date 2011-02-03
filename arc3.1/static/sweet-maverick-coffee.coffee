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

caaaar = (xs) -> car(car(car(car(xs))))
caaadr = (xs) -> car(car(car(cdr(xs))))
caadar = (xs) -> car(car(cdr(car(xs))))
caaddr = (xs) -> car(car(cdr(cdr(xs))))
cadaar = (xs) -> car(cdr(car(car(xs))))
cadadr = (xs) -> car(cdr(car(cdr(xs))))
caddar = (xs) -> car(cdr(cdr(car(xs))))
cadddr = (xs) -> car(cdr(cdr(cdr(xs))))
cdaaar = (xs) -> cdr(car(car(car(xs))))
cdaadr = (xs) -> cdr(car(car(cdr(xs))))
cdadar = (xs) -> cdr(car(cdr(car(xs))))
cdaddr = (xs) -> cdr(car(cdr(cdr(xs))))
cddaar = (xs) -> cdr(cdr(car(car(xs))))
cddadr = (xs) -> cdr(cdr(car(cdr(xs))))
cdddar = (xs) -> cdr(cdr(cdr(car(xs))))
cddddr = (xs) -> cdr(cdr(cdr(cdr(xs))))

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

apply = (f, args) ->
  ev(caddr(f), bind(cadr(f), args, cadddr(f)))

evlist = (xs, env) ->
  if xs is nil
    nil
  else
    cons(ev(car(xs), env), evlist(cdr(xs), env))

evproc = (f, args, env) ->
  if car(f) is '&procedure'
    apply f, evlist(args, env)
  else if car(f) is '&fexpr'
    apply f, args

globalEnv = nil

# shouldn't have to reference globalEnv here
evassign = (place, val, env) ->
  env = globalEnv = bind(place, ev(val, env), env)
  ev(val, env)

# can fn, car, cdr and cons be removed from here?
ev1 = (exp, env) ->
  switch car(exp)
    when 'fx' then list('&fexpr', cadr(exp), caddr(exp), env)
    when 'fn' then list('&procedure', cadr(exp), caddr(exp), env)
    when 'assign' then evassign(cadr(exp), caddr(exp), env)
    when 'eval' then ev(cadr(exp), env)
    when 'env' then env
    when 'car' then car(ev(cadr(exp), env))
    when 'cdr' then cdr(ev(cadr(exp), env))
    when 'cons' then cons(ev(cadr(exp), env), ev(caddr(exp)))
    else evproc(ev(car(exp), env), cdr(exp), env)

ev = (exp, env=globalEnv) ->
  if atom(exp) then value(exp, env) else ev1(exp, env)

ev(list('assign', 'quote', list('fx', list('exp'), 'exp')))

ev(list('assign', 't', list('quote', 't')))
ev(list('assign', 'nil', list('quote', 'nil')))
