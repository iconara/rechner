require 'rechner/compiler'

module Rechner
  describe Compiler do
    describe '.compile' do
      context 'compiles an expression to a Proc that' do
        it 'can be called' do
          expression = described_class.compile(Parser.parse('1 + 2'))
          expect(expression.call).to eq(1 + 2)
        end

        it 'can be called with named arguments as bindings for the references' do
          expression = described_class.compile(Parser.parse('1 + a'))
          expect(expression.call(a: 2)).to eq(1 + 2)
        end

        it 'raises ArgumentError when called with a referece that does not exist' do
          expression = described_class.compile(Parser.parse('1 + a'))
          expect { expression.call(b: 1) }.to raise_error(ArgumentError)
        end

        it 'raises TypeError when called without a binding for a reference' do
          expression = described_class.compile(Parser.parse('1 + a'))
          expect { expression.call }.to raise_error(TypeError)
        end

        it 'can be called with #calculate' do
          expression = described_class.compile(Parser.parse('1 + a'))
          expect(expression.calculate(a: 2)).to eq(1 + 2)
        end
      end
    end
  end
end