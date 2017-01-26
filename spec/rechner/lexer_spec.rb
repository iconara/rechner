module Rechner
  describe Lexer do
    subject :lexer do
      described_class
    end

    it 'lexes a one-char number' do
      expect(lexer.lex('1')).to eq([
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'lexes a multi-char number' do
      expect(lexer.lex('123')).to eq([
        described_class::NumberToken.new(123),
        described_class::EndToken.new,
      ])
    end

    it 'lexes an addition' do
      expect(lexer.lex('12+34')).to eq([
        described_class::NumberToken.new(12),
        described_class::PlusToken.new,
        described_class::NumberToken.new(34),
        described_class::EndToken.new,
      ])
    end

    it 'ignores whitespace at the start of the input' do
      expect(lexer.lex('  1')).to eq([
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'ignores whitespace at the end of the input' do
      expect(lexer.lex('  1')).to eq([
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'ignores whitespace between operands and operators' do
      expect(lexer.lex('1 + 1')).to eq([
        described_class::NumberToken.new(1),
        described_class::PlusToken.new,
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'lexes a one-char identifier' do
      expect(lexer.lex('a')).to eq([
        described_class::IdentifierToken.new('a'),
        described_class::EndToken.new,
      ])
    end

    it 'lexes a multi-char identifier' do
      expect(lexer.lex('abc')).to eq([
        described_class::IdentifierToken.new('abc'),
        described_class::EndToken.new,
      ])
    end

    it 'lexes an identifier with an underscore' do
      expect(lexer.lex('ab_c')).to eq([
        described_class::IdentifierToken.new('ab_c'),
        described_class::EndToken.new,
      ])
    end

    it 'lexes an identifier with numbers' do
      expect(lexer.lex('abc123')).to eq([
        described_class::IdentifierToken.new('abc123'),
        described_class::EndToken.new,
      ])
    end

    it 'lexes an addition with identifiers' do
      expect(lexer.lex('abc + def')).to eq([
        described_class::IdentifierToken.new('abc'),
        described_class::PlusToken.new,
        described_class::IdentifierToken.new('def'),
        described_class::EndToken.new,
      ])
    end

    it 'lexes an addition with identifiers and numbers' do
      expect(lexer.lex('abc + def + 123')).to eq([
        described_class::IdentifierToken.new('abc'),
        described_class::PlusToken.new,
        described_class::IdentifierToken.new('def'),
        described_class::PlusToken.new,
        described_class::NumberToken.new(123),
        described_class::EndToken.new,
      ])
    end

    it 'lexes a subtraction' do
      expect(lexer.lex('a - 1')).to eq([
        described_class::IdentifierToken.new('a'),
        described_class::MinusToken.new,
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'lexes a multiplication' do
      expect(lexer.lex('a * 1')).to eq([
        described_class::IdentifierToken.new('a'),
        described_class::MultiplicationToken.new,
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'lexes a division' do
      expect(lexer.lex('a / 1')).to eq([
        described_class::IdentifierToken.new('a'),
        described_class::DivisionToken.new,
        described_class::NumberToken.new(1),
        described_class::EndToken.new,
      ])
    end

    it 'lexes unary minus' do
      expect(lexer.lex('-a')).to eq([
        described_class::MinusToken.new,
        described_class::IdentifierToken.new('a'),
        described_class::EndToken.new,
      ])
    end

    it 'lexes parentheses' do
      expect(lexer.lex('a + 3 * (c - d)')).to eq([
        described_class::IdentifierToken.new('a'),
        described_class::PlusToken.new,
        described_class::NumberToken.new(3),
        described_class::MultiplicationToken.new,
        described_class::OpenParenthesisToken.new,
        described_class::IdentifierToken.new('c'),
        described_class::MinusToken.new,
        described_class::IdentifierToken.new('d'),
        described_class::CloseParenthesisToken.new,
        described_class::EndToken.new,
      ])
    end

    it 'raises an error when the input contains unexpected characters' do
      expect { lexer.lex('1 # 1') }.to raise_error(LexerError, 'Unexpected input "#" at position 3')
    end

    it 'raises an error when a string that starts with a number continues with letters', pending: 'numbers will have to be validated properly' do
      expect { lexer.lex('1a') }.to raise_error(LexerError, 'Unexpected input "a" at position 2')
    end

    it 'lexes ungrammatical strings' do
      expect(lexer.lex('1 1 +')).to eq([
        described_class::NumberToken.new(1),
        described_class::NumberToken.new(1),
        described_class::PlusToken.new,
        described_class::EndToken.new,
      ])
    end
  end
end
