module Rechner
  describe Lexer do
    subject :lexer do
      described_class
    end

    describe '.lex' do
      it 'lexes a one-char number' do
        expect(lexer.lex('1')).to eq([
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a multi-char number' do
        expect(lexer.lex('123')).to eq([
          described_class::NumberToken.new(123),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a decimal number' do
        expect(lexer.lex('12.3')).to eq([
          described_class::NumberToken.new(12.3),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes an addition' do
        expect(lexer.lex('12+34')).to eq([
          described_class::NumberToken.new(12),
          described_class::PlusToken::INSTANCE,
          described_class::NumberToken.new(34),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'ignores whitespace at the start of the input' do
        expect(lexer.lex('  1')).to eq([
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'ignores whitespace at the end of the input' do
        expect(lexer.lex('  1')).to eq([
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'ignores whitespace between operands and operators' do
        expect(lexer.lex('1 + 1')).to eq([
          described_class::NumberToken.new(1),
          described_class::PlusToken::INSTANCE,
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a one-char identifier' do
        expect(lexer.lex('a')).to eq([
          described_class::IdentifierToken.new('a'),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a multi-char identifier' do
        expect(lexer.lex('abc')).to eq([
          described_class::IdentifierToken.new('abc'),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes an identifier with an underscore' do
        expect(lexer.lex('ab_c')).to eq([
          described_class::IdentifierToken.new('ab_c'),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes an identifier with numbers' do
        expect(lexer.lex('abc123')).to eq([
          described_class::IdentifierToken.new('abc123'),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes an addition with identifiers' do
        expect(lexer.lex('abc + def')).to eq([
          described_class::IdentifierToken.new('abc'),
          described_class::PlusToken::INSTANCE,
          described_class::IdentifierToken.new('def'),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes an addition with identifiers and numbers' do
        expect(lexer.lex('abc + def + 123')).to eq([
          described_class::IdentifierToken.new('abc'),
          described_class::PlusToken::INSTANCE,
          described_class::IdentifierToken.new('def'),
          described_class::PlusToken::INSTANCE,
          described_class::NumberToken.new(123),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a subtraction' do
        expect(lexer.lex('a - 1')).to eq([
          described_class::IdentifierToken.new('a'),
          described_class::MinusToken::INSTANCE,
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a multiplication' do
        expect(lexer.lex('a * 1')).to eq([
          described_class::IdentifierToken.new('a'),
          described_class::MultiplicationToken::INSTANCE,
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes a division' do
        expect(lexer.lex('a / 1')).to eq([
          described_class::IdentifierToken.new('a'),
          described_class::DivisionToken::INSTANCE,
          described_class::NumberToken.new(1),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes unary minus' do
        expect(lexer.lex('-a')).to eq([
          described_class::MinusToken::INSTANCE,
          described_class::IdentifierToken.new('a'),
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'lexes parentheses' do
        expect(lexer.lex('a + 3 * (c - d)')).to eq([
          described_class::IdentifierToken.new('a'),
          described_class::PlusToken::INSTANCE,
          described_class::NumberToken.new(3),
          described_class::MultiplicationToken::INSTANCE,
          described_class::OpenParenthesisToken::INSTANCE,
          described_class::IdentifierToken.new('c'),
          described_class::MinusToken::INSTANCE,
          described_class::IdentifierToken.new('d'),
          described_class::CloseParenthesisToken::INSTANCE,
          described_class::EndToken::INSTANCE,
        ])
      end

      it 'raises an error when the input contains unexpected characters' do
        expect { lexer.lex('1 # 1') }.to raise_error(LexerError, 'Unexpected input "#" at position 2')
      end

      it 'raises an error when a string that starts with a number continues with letters', aggregate_failures: true do
        expect { lexer.lex('1a') }.to raise_error(LexerError, 'Malformed number "1a" at position 0')
        expect { lexer.lex('1..0') }.to raise_error(LexerError, 'Malformed number "1..0" at position 0')
      end

      it 'lexes ungrammatical strings' do
        expect(lexer.lex('1 1 +')).to eq([
          described_class::NumberToken.new(1),
          described_class::NumberToken.new(1),
          described_class::PlusToken::INSTANCE,
          described_class::EndToken::INSTANCE,
        ])
      end
    end

    describe '#next_token' do
      subject :lexer do
        described_class.new('1 + 2 * b')
      end

      it 'returns the next token of the character stream' do
        expect(lexer.next_token).to eq(described_class::NumberToken.new(1))
      end

      it 'does not consume the token' do
        expect(lexer.next_token).to eq(described_class::NumberToken.new(1))
        expect(lexer.next_token).to eq(described_class::NumberToken.new(1))
        expect(lexer.next_token).to eq(described_class::NumberToken.new(1))
      end

      context 'when at the end' do
        it 'returns an end token' do
          5.times do
            lexer.next_token
            lexer.consume_token
          end
          expect(lexer.next_token).to eq(described_class::EndToken::INSTANCE)
        end
      end
    end

    describe '#consume_token' do
      subject :lexer do
        described_class.new('1 + 2 * b')
      end

      it 'returns the previous token' do
        expect(lexer.consume_token).to be_nil
        lexer.next_token
        expect(lexer.consume_token).to eq(described_class::NumberToken.new(1))
      end

      it 'makes #next_token return a new token' do
        lexer.next_token
        expect(lexer.consume_token).to eq(described_class::NumberToken.new(1))
        expect(lexer.next_token).to eq(described_class::PlusToken::INSTANCE)
      end

      it 'does nothing until #next_token is called' do
        10.times { lexer.consume_token }
        expect(lexer.next_token).to eq(described_class::NumberToken.new(1))
        10.times { lexer.consume_token }
        expect(lexer.next_token).to eq(described_class::PlusToken::INSTANCE)
      end

      context 'when at the end' do
        it 'continues to return end tokens' do
          5.times do
            lexer.next_token
            lexer.consume_token
          end
          lexer.next_token
          expect(lexer.consume_token).to eq(described_class::EndToken::INSTANCE)
          lexer.next_token
          expect(lexer.consume_token).to eq(described_class::EndToken::INSTANCE)
          lexer.next_token
          expect(lexer.consume_token).to eq(described_class::EndToken::INSTANCE)
        end
      end
    end

    describe '#eof?' do
      subject :lexer do
        described_class.new('1 + 2 * b')
      end

      it 'returns false when there are more tokens' do
        expect(lexer.eof?).to be_falsy
      end

      it 'returns true when there are no more tokens' do
        5.times do
          lexer.next_token
          lexer.consume_token
        end
        expect(lexer.eof?).to be_truthy
      end
    end
  end
end
