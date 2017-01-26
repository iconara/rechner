module Rechner
  describe Parser do
    subject :parser do
      described_class
    end

    it 'parses a constant' do
      expect(parser.parse('1')).to eq(
        described_class::ConstantNode.new(1)
      )
    end

    it 'parses an addition of constants' do
      expect(parser.parse('1 + 2')).to eq(
        described_class::AdditionNode.new(
          described_class::ConstantNode.new(1),
          described_class::ConstantNode.new(2)
        )
      )
    end

    it 'parses a reference' do
      expect(parser.parse('a')).to eq(
        described_class::ReferenceNode.new('a')
      )
    end

    it 'parses an addition of references' do
      expect(parser.parse('a + b')).to eq(
        described_class::AdditionNode.new(
          described_class::ReferenceNode.new('a'),
          described_class::ReferenceNode.new('b')
        )
      )
    end

    it 'parses an string of additions' do
      expect(parser.parse('1 + a + 2 + b')).to eq(
        described_class::AdditionNode.new(
          described_class::ConstantNode.new(1),
          described_class::AdditionNode.new(
            described_class::ReferenceNode.new('a'),
            described_class::AdditionNode.new(
              described_class::ConstantNode.new(2),
              described_class::ReferenceNode.new('b')
            )
          )
        )
      )
    end

    it 'parses a multiplication' do
      expect(parser.parse('1 * a')).to eq(
        described_class::MultiplicationNode.new(
          described_class::ConstantNode.new(1),
          described_class::ReferenceNode.new('a')
        )
      )
    end

    it 'parses mixed addition and multiplication with multiplication having higher precedence' do
      expect(parser.parse('1 + a * b + 2')).to eq(
        described_class::AdditionNode.new(
          described_class::ConstantNode.new(1),
          described_class::AdditionNode.new(
            described_class::MultiplicationNode.new(
              described_class::ReferenceNode.new('a'),
              described_class::ReferenceNode.new('b')
            ),
            described_class::ConstantNode.new(2)
          )
        )
      )
    end

    it 'parses mixed subtraction and division with division having higher precedence' do
      expect(parser.parse('1 - a / b - 2')).to eq(
        described_class::SubtractionNode.new(
          described_class::ConstantNode.new(1),
          described_class::SubtractionNode.new(
            described_class::DivisionNode.new(
              described_class::ReferenceNode.new('a'),
              described_class::ReferenceNode.new('b')
            ),
            described_class::ConstantNode.new(2)
          )
        )
      )
    end

    it 'parses parenthesized expressions' do
      expect(parser.parse('(1 + 2) * 3')).to eq(
        described_class::MultiplicationNode.new(
          described_class::AdditionNode.new(
            described_class::ConstantNode.new(1),
            described_class::ConstantNode.new(2)
          ),
          described_class::ConstantNode.new(3)
        )
      )
    end

    it 'returns a tree that can describe itself' do
      expect(parser.parse('1 + (2 * (a - b) - c * 5)').to_s).to eq('(1 + ((2 * (a - b)) - (c * 5)))')
      expect(parser.parse(parser.parse('1 + (2 * (a - b) - c * 5)').to_s).to_s).to eq('(1 + ((2 * (a - b)) - (c * 5)))')
    end
  end
end
