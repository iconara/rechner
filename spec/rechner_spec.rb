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

  describe '#compile' do
    it 'returns a compiled expression' do
      expect(calculator.compile('1 + 2 * 3').calculate).to eq(1 + 2 * 3)
    end
  end
end
