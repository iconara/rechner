module Rechner
  class Parser
    def initialize(token_stream)
      @token_stream = token_stream
    end

    def self.parse(str)
      new(Lexer.new(str)).tree
    end

    def tree
      @tree ||= parse_expression
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
      expression = parse_expression
      @token_stream.consume_token
      expression
    end

    public

    class AstNode
    end

    class ConstantNode < AstNode
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

      def to_s
        @value.to_s
      end
    end

    class ReferenceNode < AstNode
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def eql?(other)
        other.is_a?(self.class) && @name.eql?(other.name)
      end
      alias_method :==, :eql?

      def hash
        @name.hash
      end

      def to_s
        @name
      end
    end

    class OperatorNode < AstNode
      attr_reader :left, :right

      def initialize(operator, left, right)
        @operator = operator
        @left = left
        @right = right
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
