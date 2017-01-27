module Rechner
  RechnerError = Class.new(StandardError)

  def self.compile(expression)
    Parser.parse(expression)
  end

  def self.calculate(expression, bindings=nil)
    compile(expression).calculate(bindings)
  end
end

require 'rechner/lexer'
require 'rechner/parser'
require 'rechner/interpreter'
