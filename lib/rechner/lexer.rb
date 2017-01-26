require 'stringio'

module Rechner
  LexerError = Class.new(RechnerError)

  class Lexer
    def initialize(str)
      @state = BaseState.new(CharacterStream.from_string(str))
      @tokens = []
    end

    def self.lex(input)
      lexer = new(input)
      tokens = []
      while (token = lexer.next_token)
        tokens << token
        lexer.consume_token
      end
      tokens
    end

    def eof?
      EndToken === @tokens.first
    end

    def next_token
      while @tokens.empty? && !@state.final?
        next_state = @state.run
        @tokens = @state.tokens.dup
        @state = next_state
      end
      @tokens.first
    end

    def consume_token
      @tokens.shift
    end

    class CharacterStream
      def initialize(input)
        @input = input
        @char = nil
      end

      def self.from_string(str)
        new(StringIO.new(str))
      end

      def eof?
        @char.nil? && @input.eof?
      end

      def position
        @input.pos
      end

      def next_char
        @char ||= @input.getc
      end

      def consume_char
        char = @char
        @char = nil
        char
      end
    end

    class Token
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def eql?(other)
        other.is_a?(self.class) && @value.eql?(other.value)
      end
      alias_method :==, :eql?

      def hash
        @value.hash
      end
    end

    class EndToken < Token
      def initialize
        super(nil)
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

    class OpenParenthesisToken < Token
      def initialize
        super('(')
      end
    end

    class CloseParenthesisToken < Token
      def initialize
        super(')')
      end
    end

    class LexerState
      attr_reader :tokens

      def initialize(input)
        @input = input
        @tokens = []
      end

      def final?
        false
      end

      def run
        self
      end

      def produce(token)
        @tokens << token
      end
    end

    class BaseState < LexerState
      WHITESPACE = /\s/
      NUMBER = /\d/
      LETTER = /\w/
      PLUS = '+'.freeze
      MINUS = '-'.freeze
      MULTIPLICATION = '*'.freeze
      DIVISION = '/'.freeze
      OPEN_PARENTHESIS = '('.freeze
      CLOSE_PARENTHESIS = ')'.freeze

      def run
        if @input.eof?
          produce(EndToken.new)
          FinalState.new(@input)
        else
          consume_whitespace
          c = @input.next_char
          case c
          when NUMBER
            produce(NumberToken.new(consume_all(NUMBER).to_i))
            self.class.new(@input)
          when LETTER
            produce(IdentifierToken.new(consume_all(LETTER)))
            self.class.new(@input)
          when PLUS
            @input.consume_char
            produce(PlusToken.new)
            self.class.new(@input)
          when MINUS
            @input.consume_char
            produce(MinusToken.new)
            self.class.new(@input)
          when MULTIPLICATION
            @input.consume_char
            produce(MultiplicationToken.new)
            self.class.new(@input)
          when DIVISION
            @input.consume_char
            produce(DivisionToken.new)
            self.class.new(@input)
          when OPEN_PARENTHESIS
            @input.consume_char
            produce(OpenParenthesisToken.new)
            self.class.new(@input)
          when CLOSE_PARENTHESIS
            @input.consume_char
            produce(CloseParenthesisToken.new)
            self.class.new(@input)
          else
            raise LexerError, "Unexpected input \"#{c}\" at position #{@input.position}"
          end
        end
      end

      def consume_whitespace
        while WHITESPACE === (c = @input.next_char)
          @input.consume_char
        end
        nil
      end

      def consume_all(matcher)
        s = ''
        while matcher === (c = @input.next_char)
          s << c
          @input.consume_char
        end
        s
      end
    end

    class FinalState < LexerState
      def final?
        true
      end
    end
  end
end
