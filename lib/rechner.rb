require 'stringio'

module Rechner
  RechnerError = Class.new(StandardError)
  LexerError = Class.new(RechnerError)

  class Lexer
    def lex(input)
      state = BaseState.new(StringIO.new(input))
      until (state = state.run).final?; end
      state.tokens
    end
  end

  class Token
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def eql?(other)
      @value.eql?(other.value)
    end
    alias_method :==, :eql?

    def hash
      @value.hash
    end
  end

  class NumberToken < Token
  end

  class IdentifierToken < Token
  end

  class PlusToken < Token
    def initialize
      super('+')
    end
  end

  class MinusToken < Token
    def initialize
      super('-')
    end
  end

  class MultiplicationToken < Token
    def initialize
      super('*')
    end
  end

  class DivisionToken < Token
    def initialize
      super('/')
    end
  end

  class OpenParenthesesToken < Token
    def initialize
      super('(')
    end
  end

  class CloseParenthesesToken < Token
    def initialize
      super(')')
    end
  end

  class LexerState
    attr_reader :tokens

    def initialize(input, tokens=[])
      @input = input
      @tokens = tokens
    end

    def final?
      false
    end

    def produce(token)
      @tokens << token
    end

    def consume_whitespace
      while (c = @input.getc) && c =~ /\s/; end
      @input.ungetc(c)
    end
  end

  class BaseState < LexerState
    def run
      if @input.eof?
        FinalState.new(@input, @tokens)
      else
        consume_whitespace
        c = @input.getc
        case c
        when /\d/
          @input.ungetc(c)
          NumberState.new(@input, @tokens)
        when /\w/
          @input.ungetc(c)
          IdentifierState.new(@input, @tokens)
        when '+'
          produce(PlusToken.new)
          self
        when '-'
          produce(MinusToken.new)
          self
        when '*'
          produce(MultiplicationToken.new)
          self
        when '/'
          produce(DivisionToken.new)
          self
        when '('
          produce(OpenParenthesesToken.new)
          self
        when ')'
          produce(CloseParenthesesToken.new)
          self
        else
          raise LexerError, "Unexpected input \"#{c}\" at position #{@input.pos}"
        end
      end
    end
  end

  class FinalState < LexerState
    def final?
      true
    end
  end

  class NumberState < LexerState
    def run
      n = ''
      while (c = @input.getc) =~ /\d/
        n << c
      end
      @input.ungetc(c)
      produce(NumberToken.new(n.to_i))
      BaseState.new(@input, @tokens)
    end
  end

  class IdentifierState < LexerState
    def run
      s = ''
      while (c = @input.getc) =~ /\w|\d/
        s << c
      end
      @input.ungetc(c)
      produce(IdentifierToken.new(s))
      BaseState.new(@input, @tokens)
    end
  end
end
