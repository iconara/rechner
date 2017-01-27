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
      when Lexer::NumberToken
        ConstantExpression.new(token.value)
      when Lexer::IdentifierToken
        ReferenceExpression.new(token.value)
      when Lexer::OpenParenthesisToken
        parse_group
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

    class Calculator
      def initialize(bindings=nil)
        @bindings = bindings || {}
      end

      def visit_constant(constant_expression)
        constant_expression.value
      end

      def visit_reference(reference_expression)
        if (value = @bindings[reference_expression.name])
          value
        else
          raise ReferenceError, "No binding for \"#{reference_expression.name}\""
        end
      end

      def visit_addition(left_expression, right_expression)
        left_expression.accept(self) + right_expression.accept(self)
      end

      def visit_subtraction(left_expression, right_expression)
        left_expression.accept(self) - right_expression.accept(self)
      end

      def visit_multiplication(left_expression, right_expression)
        left_expression.accept(self) * right_expression.accept(self)
      end

      def visit_division(left_expression, right_expression)
        left_expression.accept(self) / right_expression.accept(self)
      end
    end

    class ReferenceFinder
      def visit_constant(constant_expression)
        []
      end

      def visit_reference(reference_expression)
        [reference_expression.name]
      end

      def visit_addition(left_expression, right_expression)
        left_expression.accept(self) | right_expression.accept(self)
      end

      def visit_subtraction(left_expression, right_expression)
        left_expression.accept(self) | right_expression.accept(self)
      end

      def visit_multiplication(left_expression, right_expression)
        left_expression.accept(self) | right_expression.accept(self)
      end

      def visit_division(left_expression, right_expression)
        left_expression.accept(self) | right_expression.accept(self)
      end
    end

    class Expression
      def calculate(bindings=nil)
        nil
      end

      def references
        accept(ReferenceFinder.new)
      end

      def calculate(bindings=nil)
        accept(Calculator.new(bindings))
      end

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

    class AdditionExpression < OperatorExpression
      def initialize(left, right)
        super(:+, left, right)
      end

      def accept(visitor)
        visitor.visit_addition(@left, @right)
      end
    end

    class SubtractionExpression < OperatorExpression
      def initialize(left, right)
        super(:-, left, right)
      end

      def accept(visitor)
        visitor.visit_subtraction(@left, @right)
      end
    end

    class MultiplicationExpression < OperatorExpression
      def initialize(left, right)
        super(:*, left, right)
      end

      def accept(visitor)
        visitor.visit_multiplication(@left, @right)
      end
    end

    class DivisionExpression < OperatorExpression
      def initialize(left, right)
        super(:/, left, right)
      end

      def accept(visitor)
        visitor.visit_division(self, self, @left, @right)
      end
    end
  end
end
