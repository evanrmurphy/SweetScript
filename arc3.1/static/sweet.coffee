# depends on underscore.js

test = (name, x, expected) ->
  unless _(x).isEqual(expected)
    console.log "#{name} test failed"

t = true
nil = null

isarray = (x) ->
  if (x and (typeof x is 'object') and
            (x.constructor is Array)) then t else nil

acons = isarray

atom = (x) ->
  if acons(x) then nil else t

cons = (a, d) -> [a, d]
test('cons #1', cons(1, nil), [1, nil])

car = (xs) -> xs[0]
test('car #1', car(cons(1, nil)), 1)

cdr = (xs) -> xs[1]
test('cdr #1', cdr(cons(1, nil)), nil)

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

test('len #1', len(nil), 0)
test('len #2', len(cons(1, nil)), 1)
test('len #3', len(cons(1, cons(2, nil))), 2)

arraylist = (a) ->
  if a.length == 0 then nil else cons a[0], arraylist(a[1..])

test('arraylist #1', arraylist([]), nil)
test('arraylist #2', arraylist([1]), cons(1, nil))
test('arraylist #3', arraylist([1, 2]), cons(1, cons(2, nil)))

list = (args...) -> arraylist(args)

test('list #1', list(), nil)
test('list #2', list(1), cons(1, nil))
test('list #3', list(1, 2), cons(1, cons(2, nil)))

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

test('bind #1', bind(list('x'), list(1), nil), list(cons(list('x'), list(1))))

apply = (f, args) ->
  ev(caddr(f), bind(cadr(f), args, cadddr(f)))

evlist = (xs, env) ->
  if xs is nil
    nil
  else
    cons(ev(car(xs), env), evlist(cdr(xs), env))

evproc = (f, args, env) ->
  if car(f) is '#<procedure>'
    apply f, evlist(args, env)
  else if car(f) is '#<fexpr>'
    apply f, args

globalEnv = nil

# shouldn't have to reference globalEnv here
evassign = (place, val, env) ->
  env = globalEnv = bind(place, ev(val, env), env)
  ev(val, env)

# can fn, car, cdr and cons be removed from here?
ev1 = (s, env) ->
  switch car(s)
    when 'vau' then list('#<fexpr>', cadr(s), caddr(s), env)
    when 'fn' then list('#<procedure>', cadr(s), caddr(s), env)
    when 'assign' then evassign(cadr(s), caddr(s), env)
    when 'eval' then ev(cadr(s), env)
    when 'cons' then cons(ev(cadr(s), env), ev(caddr(s), env))
    when 'car' then car(ev(cadr(s), env))
    when 'cdr' then cdr(ev(cadr(s), env))
    else evproc(ev(car(s), env), cdr(s), env)

ev = (s, env=globalEnv) ->
  if atom(s) then value(s, env) else ev1(s, env)

# recursive arraylist
rarraylist = (a) ->
  if a.length == 0
    nil
  else if isarray a[0]
    cons rarraylist(a[0]), rarraylist(a[1..])
  else
    cons a[0], rarraylist(a[1..])

test('rarraylist #1', rarraylist([]), nil)
test('rarraylist #2', rarraylist([1]), list(1))
test('rarraylist #3', rarraylist([1, 2, 3]), list(1, 2, 3))
test('rarraylist #4', rarraylist([1, [2, 3], 4]), list(1, list(2, 3), 4))

tokensrarray = (ts) ->
  tok = ts.shift()
  if tok == '('
    acc = []
    while ts[0] != ')'
      acc.push(tokensrarray ts)
    ts.shift() # pop off ')'
    acc
  else
    tok

tokenize = (s) ->
  spaced = s.replace(/\(/g,' ( ').replace(/\)/g,' ) ').split(' ')
  _(spaced).without('') # purge of empty string tokens

read = (s) ->
  acc = tokensrarray tokenize(s)
  if isarray acc then rarraylist acc else acc

test('read #1', read('t'), 't')
test('read #2', read('nil'), 'nil')
test('read #3', read('(1)'), list('1'))
test('read #4', read('(foo bar)'), list('foo', 'bar'))

isfn = (x) ->
  if acons(x) and car(x) is '#<procedure>' then t else nil

isfexpr = (x) ->
  if acons(x) and (car(x) is '#<fexpr>') then t else nil

tostr = (s) ->
  if atom s
    if s is nil then 'nil' else s
  else if isfn(s) then '#<procedure>'
  else if isfexpr(s) then '#<fexpr>'
  else
    "(#{tostr car(s)} . #{tostr cdr(s)})"

test('tostr #1', tostr(nil), 'nil')
test('tostr #2', tostr(list(1)), '(1 . nil)')
test('tostr #3', tostr(list(1, 2)), '(1 . (2 . nil))')

X = (s) -> tostr(ev(read(s)))

test('vau #1', X('((vau () nil))'), 'nil')
test('vau #2', X('((vau (x) x) y)'), 'y')

X('(assign quote (vau (x) x))')

test('quote #1', X('(quote a)'), 'a')
test('quote #2', X('(quote (a b))'), tostr(list('a', 'b')))

test('fn #1', X('((fn () nil))'), 'nil')
test('fn #2', X('((fn (x) x) (quote a))'), 'a')
test('fn #3', X('((fn (x y) (cons x y)) (quote a) (quote b)))'), '(a . b)')

X('(assign t (quote t))')
X('(assign nil (quote nil))')

test('t #1', X('t'), 't')
test('nil #1', X('nil'), 'nil')

X('(assign caar (fn (xs) (car (car xs))))')
X('(assign cadr (fn (xs) (car (cdr xs))))')
X('(assign cdar (fn (xs) (cdr (car xs))))')
X('(assign cddr (fn (xs) (cdr (cdr xs))))')


