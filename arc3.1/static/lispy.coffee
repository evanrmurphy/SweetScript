# http://norvig.com/lispy.html

# http://javascript.crockford.com/remedial.html
typeOf = (value) ->
  s = typeof value
  if s is 'object'
    if value
      if value instanceof Array
        s = 'array'
      else
        s = 'null'
  s

isa = (x, y) ->
  typeOf(x) is y

Symbol = "string"
list = "array"

class Env
  constructor: (parms=[], args=[], outer=null) ->
    _(_.zip parms, args).each (keyVal) ->
      [key, val] = keyVal
      this[key] = val
    @outer = outer
  find: (Var) ->
    if Var of this then this else @outer.find(Var)

Eval = (x, env=globalEnv) ->
  if isa x, Symbol              # variable reference
    env.find(x)[x]
  else if isa x, list           # constant literal
    x
  else if x[0] is 'quote'       # (quote exp)
    [_, exp] = x
    exp
  else if x[0] is 'if'          # (if test conseq alt)
    [_, test, conseq, alt] = x
    Eval (if Eval(test, env) then conseq else alt), env
  else if x[0] is 'set!'        # (set! var exp)
    [_, Var, exp] = x
    env.find(Var)[Var] = Eval exp, env
  else if x[0] is 'define'      # (define var exp)
    [_, Var, exp] = x
    env[Var] = Eval exp, env
  else if x[0] is 'lambda'      # (lambda (var*) exp)
    [_, vars, exp] = x
    (args...) -> Eval exp, Env(vars, args, env)
  else if x[0] is 'begin'       # (begin exp*)
    val = Eval(exp, env) for exp in x[1..]
    val
  else                          # (proc exp*)
    exps = (Eval exp, env for exp in x)
    proc = exps.shift()
    proc exps
