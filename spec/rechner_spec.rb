describe Rechner do
  subject :calculator do
    described_class
  end

  describe '#calculate' do
    it 'calculates the value of an expression' do
      expect(calculator.calculate('1 + 2')).to eq(1 + 2)
    end

    context 'with references and bindings' do
      it 'calculates the value of an expression' do
        expect(calculator.calculate('1 + a', a: 2)).to eq(1 + 2)
      end
    end
  end

  describe '#parse' do
    it 'returns a reusable expression object' do
      expression = calculator.parse('1 + 2 * a')
      expect(expression.calculate(a: 3)).to eq(1 + 2 * 3)
      expect(expression.calculate(a: 5)).to eq(1 + 2 * 5)
    end
  end

  describe '#compile' do
    it 'returns a reusable expression object', aggregate_failures: true do
      expression = calculator.compile('1 + 2 * a')
      expect(expression.calculate(a: 3)).to eq(1 + 2 * 3)
      expect(expression.calculate(a: 5)).to eq(1 + 2 * 5)
    end
  end
end
