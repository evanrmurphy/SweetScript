# Used as a guide: http://norvig.com/lispy.html

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

################ Symbol, Procedure, Env classes

Symbol = "string"
list = "array"

class Env
  constructor: (parms=[], args=[], outer=null) ->
    _(_.zip parms, args).each (keyVal) ->
      [key, val] = keyVal
      this[key] = val
    @outer = outer
  find: (Var) ->
    if Var of this then this else @outer?.find(Var)

# This will grow fast, should move to separate file or something
addGlobals = (env) ->
  _(env).extend
    '+': (args...) ->
      acc = 0
      _(args).each (x) -> acc += x
      acc
    '-': (args...) ->
      acc = args[0]
      _(args[1..]).each (x) -> acc -= x
      acc
    '*': (args...) ->
      acc = 1
      _(args).each (x) -> acc *= x
      acc
    '/': (args...) ->
      acc = args[0]
      _(args[1..]).each (x) -> acc /= x
      acc
    'cons': (x,y) -> [x].concat(y)
    'car': (xs) -> xs[0]
    'cdr': (xs) -> xs[1..]
  env

globalEnv = addGlobals(new Env)

################ Eval

Eval = (x, env=globalEnv) ->
  if isa x, Symbol              # variable reference
    env.find(x)[x]
  else if not isa x, list       # constant literal
    x
  else if x[0] is 'quote'       # (quote exp)
    [_, exp] = x
    exp
  else if x[0] is 'if'          # (if test conseq alt)
    [_, test, conseq, alt] = x
    branch = (if Eval(test, env) then conseq else alt)
    Eval branch, env
  else if x[0] is '='           # (= var exp)
    [_, Var, exp] = x
    scope = (if env.find(Var) then env.find(Var) else globalEnv)
    scope[Var] = Eval exp, env
  else if x[0] is 'fn'          # (fn (var*) exp)
    [_, vars, exp] = x
    (args...) -> Eval exp, new Env(vars, args, env)
  else if x[0] is 'do'          # (do exp*)
    val = Eval(exp, env) for exp in x[1..]
    val
  else                          # (proc exp*)
    exps = (Eval(exp, env) for exp in x)
    proc = exps.shift()
    proc exps...

################ parse, read and user interaction

read = (s) ->
  readFrom tokenize(s)

parse = read

tokenize = (s) ->
  spaced = s.replace(/\(/g,' ( ').replace(/\)/g,' ) ').split(' ')
  _(spaced).without('') # purge of empty string tokens

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

atom = (token) ->
  if token.match /^\d+\.?$/
    parseInt token
  else if token.match /^\d*\.\d+$/
    parseFloat token
  else
    "#{token}"

ToString = (exp) ->
  if isa exp, list
    '(' + (_(exp).map ToString).join(' ') + ')'
  else
    exp.toString()

repl = (p='sweet> ') ->
  while true
    val = Eval(parse(prompt p))
    alert(ToString val)

sweet = (exp) -> Eval(parse exp)

window.repl = repl
window.read = read
window.parse = parse
window.tokenize = tokenize
window.ToString = ToString
window.atom = atom
window.Env = Env
window.globalEnv = globalEnv
window.Eval = Eval
window.sweet = sweet

# repl()
