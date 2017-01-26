module Rechner
  RechnerError = Class.new(StandardError)
end

require 'rechner/lexer'
require 'rechner/parser'
