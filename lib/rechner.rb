module Rechner
  RechnerError = Class.new(StandardError)

  def self.calculate(expression, bindings=nil)
    Parser.parse(expression).calculate(bindings)
  end
end

require 'rechner/lexer'
require 'rechner/parser'
