module Rechner
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

  module ExpressionCalculator
    def references
      accept(ReferenceFinder.new)
    end

    def calculate(bindings=nil)
      accept(Calculator.new(bindings))
    end
  end

  class Parser::Expression
    include ExpressionCalculator
  end
end
