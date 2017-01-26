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

      def consume_whitespace
        while (c = next_char) && c =~ /\s/
          consume_char
        end
        nil
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
      def run
        if @input.eof?
          produce(EndToken.new)
          FinalState.new(@input)
        else
          @input.consume_whitespace
          c = @input.next_char
          case c
          when /\d/
            NumberState.new(@input)
          when /\w/
            IdentifierState.new(@input)
          when '+'
            @input.consume_char
            produce(PlusToken.new)
            self.class.new(@input)
          when '-'
            @input.consume_char
            produce(MinusToken.new)
            self.class.new(@input)
          when '*'
            @input.consume_char
            produce(MultiplicationToken.new)
            self.class.new(@input)
          when '/'
            @input.consume_char
            produce(DivisionToken.new)
            self.class.new(@input)
          when '('
            @input.consume_char
            produce(OpenParenthesesToken.new)
            self.class.new(@input)
          when ')'
            @input.consume_char
            produce(CloseParenthesesToken.new)
            self.class.new(@input)
          else
            raise LexerError, "Unexpected input \"#{c}\" at position #{@input.position}"
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
        while (c = @input.next_char) =~ /\d/
          n << c
          @input.consume_char
        end
        produce(NumberToken.new(n.to_i))
        BaseState.new(@input)
      end
    end

    class IdentifierState < LexerState
      def run
        s = ''
        while (c = @input.next_char) =~ /\w|\d/
          s << c
          @input.consume_char
        end
        produce(IdentifierToken.new(s))
        BaseState.new(@input)
      end
    end
  end
end
