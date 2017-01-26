module Rechner
  ParseError = Class.new(RechnerError)
  ReferenceError = Class.new(RechnerError)

  class Parser
    def initialize(token_stream)
      @token_stream = token_stream
    end

    def self.parse(str)
      new(Lexer.new(str)).expression
    end

    def expression
      @tree ||= begin
        expr = parse_expression
        unless @token_stream.eof?
          raise ParseError, 'Trailing tokens after expression'
        end
        expr
      end
    end

    private

    def parse_expression
      term = parse_term
      token = @token_stream.next_token
      case token
      when Lexer::PlusToken
        @token_stream.consume_token
        AdditionNode.new(term, parse_expression)
      when Lexer::MinusToken
        @token_stream.consume_token
        SubtractionNode.new(term, parse_expression)
      else
        term
      end
    end

    def parse_term
      factor = parse_factor
      token = @token_stream.next_token
      case token
      when Lexer::MultiplicationToken
        @token_stream.consume_token
        MultiplicationNode.new(factor, parse_term)
      when Lexer::DivisionToken
        @token_stream.consume_token
        DivisionNode.new(factor, parse_term)
      else
        factor
      end
    end

    def parse_factor
      token = @token_stream.next_token
      @token_stream.consume_token
      case token
      when Lexer::NumberToken
        ConstantNode.new(token.value)
      when Lexer::IdentifierToken
        ReferenceNode.new(token.value)
      when Lexer::OpenParenthesesToken
        parse_parentheses
      end
    end

    def parse_parentheses
      expr = parse_expression
      if Lexer::CloseParenthesesToken === @token_stream.next_token
        @token_stream.consume_token
      else
        raise ParseError, 'Missing closing parenthesis'
      end
      expr
    end

    public

    class AstNode
      def calculate(bindings=nil)
        nil
      end
    end

    class ConstantNode < AstNode
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def calculate(bindings=nil)
        @value
      end

      def eql?(other)
        other.is_a?(self.class) && @value.eql?(other.value)
      end
      alias_method :==, :eql?

      def hash
        @value.hash
      end

      def to_s
        @value.to_s
      end
    end

    class ReferenceNode < AstNode
      attr_reader :name

      def initialize(name)
        @name = name.to_sym
      end

      def calculate(bindings=nil)
        if bindings && (value = bindings[@name])
          value
        else
          raise ReferenceError, "No binding for \"#{@name}\""
        end
      end

      def eql?(other)
        other.is_a?(self.class) && @name.eql?(other.name)
      end
      alias_method :==, :eql?

      def hash
        @name.hash
      end

      def to_s
        @name.to_s
      end
    end

    class OperatorNode < AstNode
      attr_reader :left, :right

      def initialize(operator, left, right)
        @operator = operator
        @left = left
        @right = right
      end

      def calculate(bindings=nil)
        @left.calculate(bindings).send(@operator, @right.calculate(bindings))
      end

      def eql?(other)
        other.is_a?(self.class) && @left.eql?(other.left) && @right.eql?(other.right)
      end
      alias_method :==, :eql?

      def hash
        (@left.hash * 31) ^ @right.hash
      end

      def to_s
        "(#{@left} #{@operator} #{@right})"
      end
    end

    class AdditionNode < OperatorNode
      def initialize(left, right)
        super(:+, left, right)
      end
    end

    class SubtractionNode < OperatorNode
      def initialize(left, right)
        super(:-, left, right)
      end
    end

    class MultiplicationNode < OperatorNode
      def initialize(left, right)
        super(:*, left, right)
      end
    end

    class DivisionNode < OperatorNode
      def initialize(left, right)
        super(:/, left, right)
      end
    end
  end
end
