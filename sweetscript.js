SweetScript = {};

SweetScript.Env = function(dict) {

  def __init__(self, parms=(), args=(), outer=None):
    self.update(zip(parms,args))
    self.outer = outer

  var find = function(self, v) {
    if (self[v]) {
      return self;
    } else {
      self.outer.find(v);
    }
  }
}

SweetScript.global_env = add_globals(Env())

SweetScript.eval = function(x, env) {

  if (env == null) {
    env = global_env;
  }

  if (typeof x == "string") {
    return env.find(x)[x];
  } else if (x instanceof Array) {
    return x;
  } else if (x[0] == 'quote') {
    
  } else if (x[0] == 'if') {
    
  } else if (x[0] == '=') {
    
  } else if (x[0] == 'function') {
    
  } else if (x[0] == 'do') {

  } else {

  }
}

