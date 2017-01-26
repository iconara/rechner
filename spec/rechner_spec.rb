module Rechner
  describe Lexer do
    subject :lexer do
      described_class
    end

    it 'lexes a one-char number' do
      expect(lexer.lex('1')).to eq([
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'lexes a multi-char number' do
      expect(lexer.lex('123')).to eq([
        NumberToken.new(123),
        EndToken.new,
      ])
    end

    it 'lexes an addition' do
      expect(lexer.lex('12+34')).to eq([
        NumberToken.new(12),
        PlusToken.new,
        NumberToken.new(34),
        EndToken.new,
      ])
    end

    it 'ignores whitespace at the start of the input' do
      expect(lexer.lex('  1')).to eq([
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'ignores whitespace at the end of the input' do
      expect(lexer.lex('  1')).to eq([
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'ignores whitespace between operands and operators' do
      expect(lexer.lex('1 + 1')).to eq([
        NumberToken.new(1),
        PlusToken.new,
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'lexes a one-char identifier' do
      expect(lexer.lex('a')).to eq([
        IdentifierToken.new('a'),
        EndToken.new,
      ])
    end

    it 'lexes a multi-char identifier' do
      expect(lexer.lex('abc')).to eq([
        IdentifierToken.new('abc'),
        EndToken.new,
      ])
    end

    it 'lexes an identifier with an underscore' do
      expect(lexer.lex('ab_c')).to eq([
        IdentifierToken.new('ab_c'),
        EndToken.new,
      ])
    end

    it 'lexes an identifier with numbers' do
      expect(lexer.lex('abc123')).to eq([
        IdentifierToken.new('abc123'),
        EndToken.new,
      ])
    end

    it 'lexes an addition with identifiers' do
      expect(lexer.lex('abc + def')).to eq([
        IdentifierToken.new('abc'),
        PlusToken.new,
        IdentifierToken.new('def'),
        EndToken.new,
      ])
    end

    it 'lexes an addition with identifiers and numbers' do
      expect(lexer.lex('abc + def + 123')).to eq([
        IdentifierToken.new('abc'),
        PlusToken.new,
        IdentifierToken.new('def'),
        PlusToken.new,
        NumberToken.new(123),
        EndToken.new,
      ])
    end

    it 'lexes a subtraction' do
      expect(lexer.lex('a - 1')).to eq([
        IdentifierToken.new('a'),
        MinusToken.new,
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'lexes a multiplication' do
      expect(lexer.lex('a * 1')).to eq([
        IdentifierToken.new('a'),
        MultiplicationToken.new,
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'lexes a division' do
      expect(lexer.lex('a / 1')).to eq([
        IdentifierToken.new('a'),
        DivisionToken.new,
        NumberToken.new(1),
        EndToken.new,
      ])
    end

    it 'lexes unary minus' do
      expect(lexer.lex('-a')).to eq([
        MinusToken.new,
        IdentifierToken.new('a'),
        EndToken.new,
      ])
    end

    it 'lexes parentheses' do
      expect(lexer.lex('a + 3 * (c - d)')).to eq([
        IdentifierToken.new('a'),
        PlusToken.new,
        NumberToken.new(3),
        MultiplicationToken.new,
        OpenParenthesesToken.new,
        IdentifierToken.new('c'),
        MinusToken.new,
        IdentifierToken.new('d'),
        CloseParenthesesToken.new,
        EndToken.new,
      ])
    end

    it 'raises an error when the input contains unexpected characters' do
      expect { lexer.lex('1 # 1') }.to raise_error(LexerError, 'Unexpected input "#" at position 3')
    end

    it 'lexes ungrammatical strings' do
      expect(lexer.lex('1 1 +')).to eq([
        NumberToken.new(1),
        NumberToken.new(1),
        PlusToken.new,
        EndToken.new,
      ])
    end
  end
end
