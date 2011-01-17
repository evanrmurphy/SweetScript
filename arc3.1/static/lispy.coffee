# JavaScript port of http://norvig.com/lispy.html

################ Symbol, Procedure, Env classes

# Borrowed from http://javascript.crockford.com/remedial.html
# to help distinguish arrays from other objects
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

globalEnv = new Env

################ Eval

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
  else if x[0] is '='           # (= var exp)
    [_, Var, exp] = x
    env.find(Var)[Var] = Eval exp, env
  else if x[0] is 'define'      # (define var exp)
    [_, Var, exp] = x
    env[Var] = Eval exp, env
  else if x[0] is 'fn'          # (fn (var*) exp)
    [_, vars, exp] = x
    (args...) -> Eval exp, Env(vars, args, env)
  else if x[0] is 'do'          # (do exp*)
    val = Eval(exp, env) for exp in x[1..]
    val
  else                          # (proc exp*)
    exps = (Eval exp, env for exp in x)
    proc = exps.shift()
    proc exps

################ parse, read, and user interaction

read = (s) ->
  readFrom tokenize(s)

tokenize = (s) ->
  _(s.replace('(',' ( ').replace(')',' ) ').split(' ')).without('')

readFrom = (tokens) ->
  if tokens.length == 0
    alert 'unexpected EOF while reading'
  token = tokens.shift()
  if '(' == token
    L = []
    while tokens[0] != ')'
      L.push(readFrom tokens)
    tokens.shift() # pop off ')'
    L
  else if ')' == token
    alert 'unexpected )'
  else
    atom token

# Still needs to distinguish numbers from symbols
atom = (token) ->
  token.toString()

ToString = (exp) ->
  if isa exp, list
    '(' + (_(exp).map ToString).join(' ') + ')'
  else
    exp.toString()

# Could use better UI than prompt + alert
repl = (p='lis.py> ') ->
  while input != '(quit)'
    input = (prompt p)
    val = Eval(read input)
    alert(ToString val)

window.repl = repl
window.read = read
window.tokenize = tokenize
window.ToString = ToString
window.atom = atom

repl()
