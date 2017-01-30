module Rechner
  RechnerError = Class.new(StandardError)

  def self.parse(expression)
    Parser.parse(expression)
  end

  def self.compile(expression)
    Compiler.compile(parse(expression))
  end

  def self.calculate(expression, bindings=nil)
    parse(expression).calculate(bindings)
  end
end

require 'rechner/lexer'
require 'rechner/parser'
require 'rechner/interpreter'
require 'rechner/compiler'
