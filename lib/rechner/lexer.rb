require 'stringio'

module Rechner
  LexerError = Class.new(RechnerError)

  class Lexer
    def initialize(str)
      @character_stream = CharacterStream.from_string(str)
      @token = nil
    end

    def self.lex(input)
      lexer = new(input)
      tokens = []
      until lexer.eof?
        tokens << lexer.next_token
        lexer.consume_token
      end
      tokens << lexer.next_token
      tokens
    end

    def eof?
      EndToken === next_token
    end

    def next_token
      @token ||= produce_next_token
    end

    def consume_token
      token = @token
      @token = nil
      token
    end

    private

    WHITESPACE = /\s/
    NUMBER = /\d/
    LETTER = /\w/
    PLUS = '+'.freeze
    MINUS = '-'.freeze
    MULTIPLICATION = '*'.freeze
    DIVISION = '/'.freeze
    OPEN_PARENTHESIS = '('.freeze
    CLOSE_PARENTHESIS = ')'.freeze

    def produce_next_token
      if @character_stream.eof?
        EndToken.new
      else
        consume_whitespace
        c = @character_stream.next_char
        case c
        when NUMBER
          NumberToken.new(consume_all(NUMBER).to_i)
        when LETTER
          IdentifierToken.new(consume_all(LETTER))
        when PLUS
          @character_stream.consume_char
          PlusToken.new
        when MINUS
          @character_stream.consume_char
          MinusToken.new
        when MULTIPLICATION
          @character_stream.consume_char
          MultiplicationToken.new
        when DIVISION
          @character_stream.consume_char
          DivisionToken.new
        when OPEN_PARENTHESIS
          @character_stream.consume_char
          OpenParenthesisToken.new
        when CLOSE_PARENTHESIS
          @character_stream.consume_char
          CloseParenthesisToken.new
        else
          raise LexerError, "Unexpected input \"#{c}\" at position #{@character_stream.position}"
        end
      end
    end

    def consume_whitespace
      while WHITESPACE === (c = @character_stream.next_char)
        @character_stream.consume_char
      end
      nil
    end

    def consume_all(matcher)
      s = ''
      while matcher === (c = @character_stream.next_char)
        s << c
        @character_stream.consume_char
      end
      s
    end

    public

    class CharacterStream
      def initialize(io)
        @io = io
        @char = nil
      end

      def self.from_string(str)
        new(StringIO.new(str))
      end

      def eof?
        @char.nil? && @io.eof?
      end

      def position
        @io.pos
      end

      def next_char
        @char ||= @io.getc
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
  end
end
