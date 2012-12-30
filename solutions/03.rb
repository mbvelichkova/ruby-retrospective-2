class Expr
  def self.build(expr)
    operation, left_operand, right_operand = expr
 
    case operation
    when :number then Number.new left_operand
    when :variable then Variable.new left_operand
    when :- then Negation.new Expr.build(left_operand)
    when :+ then Addition.new Expr.build(left_operand), Expr.build(right_operand)
    when :* then Multiplication.new Expr.build(left_operand), Expr.build(right_operand)
    when :sin then Sine.new Expr.build(left_operand)
    when :cos then Cosine.new Expr.build(left_operand)
    end
  end
 
  def +(other)
    Addition.new self, other
  end
 
  def -@
    Negation.new self
  end
 
  def *(other)
    Multiplication.new self, other
  end
end
 
class Unary < Expr
  attr_reader :operand
 
  def initialize(operand)
    @operand = operand
  end
 
  def ==(other)
    self.class == other.class and
    self.operand == other.operand
  end
 
  def simplify
    self
  end
 
  def exact?
    @operand.exact?
  end
end
 
class Binary < Expr
  attr_reader :left_operand, :right_operand
 
  def initialize(left_operand, right_operand)
    @left_operand = left_operand
    @right_operand = right_operand
  end
 
  def ==(other)
    self.class == other.class and
    self.left_operand == other.left_operand and
    self.right_operand == other.right_operand
  end
 
  def simplify
    self.class.new left_operand.simplify, right_operand.simplify
  end
 
  def exact?
    left_operand.exact? and right_operand.exact?
  end
end
 
class Number < Unary
  def evaluate(environment = {})
    operand
  end
 
  def derive(variable)
    Number.new(0)
  end
 
  def exact?
    true
  end
end
 
class Variable < Unary
  def evaluate(environment = {})
    raise ArgumentError, "The variable is uninitialized!" unless environment.has_key? operand
    environment[operand]
  end
 
  def derive(variable)
    variable == operand ? Number.new(1) : Number.new(0)
  end
 
  def exact?
    false
  end
end
 
class Negation < Unary
  def evaluate(environment = {})
    -operand.evaluate(environment)
  end
 
  def derive(variable)
    Negation.new operand.derive(variable)
  end
 
  def simplify
    if exact?
      Number.new(-operand.simplify.evaluate)
    else
      Negation.new(operand.simplify)
    end
  end
 
  def exact?
    operand.exact?
  end
end
 
class Sine < Unary
  def evaluate(environment = {})
    Math.sin operand.evaluate(environment)
  end
 
  def derive(variable)
    (operand.derive(variable) * (Cosine.new operand)).simplify
  end
 
  def simplify
    if exact?
      Number.new Math.sin(operand.simplify.evaluate)
    else
      Sine.new operand.simplify
    end
  end
end
 
class Cosine < Unary
  def evaluate(environment = {})
    Math.cos operand.evaluate(environment)
  end
 
  def derive(variable)
    (operand.derive(variable) * -(Sine.new operand)).simplify
  end
 
  def simplify
    if exact?
      Number.new Math.cos(operand.simplify.evaluate)
    else
      Cosine.new operand.simplify
    end
  end
end
 
class Addition < Binary
  def evaluate(environment = {})
    left_operand.evaluate(environment) + right_operand.evaluate(environment)
  end
 
  def derive(variable)
    (left_operand.derive(variable) + right_operand.derive(variable)).simplify
  end
 
  def simplify
    if exact?
      Number.new(left_operand.simplify.evaluate + right_operand.simplify.evaluate)
    elsif left_operand == Number.new(0)
      right_operand.simplify
    elsif right_operand == Number.new(0)
      left_operand.simplify
    else
      super
    end
  end
end
 
class Multiplication < Binary
  def evaluate(environment = {})
    left_operand.evaluate(environment) * right_operand.evaluate(environment)
  end
 
  def derive(variable)
    (left_operand.derive(variable) * right_operand +
     left_operand * right_operand.derive(variable)).simplify
  end
 
  def simplify
    if exact?
      Number.new(left_operand.simplify.evaluate * right_operand.simplify.evaluate)
    elsif left_operand.simplify == Number.new(0) or right_operand.simplify == Number.new(0)
      Number.new(0)
    elsif left_operand.simplify == Number.new(1)
      right_operand.simplify
    elsif right_operand.simplify == Number.new(1)
      left_operand.simplify
    else
      super
    end
  end
end
