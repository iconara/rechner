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
      @expression ||= begin
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
        AdditionExpression.new(term, parse_expression)
      when Lexer::MinusToken
        @token_stream.consume_token
        SubtractionExpression.new(term, parse_expression)
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
        MultiplicationExpression.new(factor, parse_term)
      when Lexer::DivisionToken
        @token_stream.consume_token
        DivisionExpression.new(factor, parse_term)
      else
        factor
      end
    end

    def parse_factor
      token = @token_stream.next_token
      @token_stream.consume_token
      case token
      when Lexer::MinusToken
        factor = parse_factor
        case factor
        when ConstantExpression
          ConstantExpression.new(-factor.value)
        when ReferenceExpression
          MultiplicationExpression.new(
            ConstantExpression.new(-1),
            factor
          )
        end
      when Lexer::NumberToken
        ConstantExpression.new(token.value)
      when Lexer::IdentifierToken
        ReferenceExpression.new(token.value)
      when Lexer::OpenParenthesisToken
        parse_group
      else
        raise ParseError, format('Illegal token in factor: %p', token.value)
      end
    end

    def parse_group
      expr = parse_expression
      if Lexer::CloseParenthesisToken === @token_stream.next_token
        @token_stream.consume_token
      else
        raise ParseError, 'Missing closing parenthesis'
      end
      expr
    end

    public

    class Expression
      def accept(visitor)
      end
    end

    class ConstantExpression < Expression
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def accept(visitor)
        visitor.visit_constant(self)
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

    class ReferenceExpression < Expression
      attr_reader :name

      def initialize(name)
        @name = name.to_sym
      end

      def accept(visitor)
        visitor.visit_reference(self)
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

    class OperatorExpression < Expression
      attr_reader :operator, :left, :right

      def initialize(operator, left, right)
        @operator = operator
        @left = left
        @right = right
      end

      def accept(visitor)
        visitor.visit_operator(self)
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

    class AdditionExpression < OperatorExpression
      def initialize(left, right)
        super(:+, left, right)
      end
    end

    class SubtractionExpression < OperatorExpression
      def initialize(left, right)
        super(:-, left, right)
      end
    end

    class MultiplicationExpression < OperatorExpression
      def initialize(left, right)
        super(:*, left, right)
      end
    end

    class DivisionExpression < OperatorExpression
      def initialize(left, right)
        super(:/, left, right)
      end
    end
  end
end
