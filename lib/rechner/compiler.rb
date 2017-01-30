module Rechner
  class Compiler
    def self.compile(expression)
      references = expression.references.map { |name| "#{name}: nil" }.join(', ')
      expression = ::Kernel.eval(%Q<lambda { |#{references}| #{expression.to_s} }>)
      expression.singleton_class.send(:alias_method, :calculate, :call)
      expression
    end
  end
end
