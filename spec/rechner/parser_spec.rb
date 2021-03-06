module Rechner
  describe Parser do
    subject :parser do
      described_class
    end

    describe '.parse' do
      it 'parses a constant' do
        expect(parser.parse('1')).to eq(
          described_class::ConstantExpression.new(1)
        )
      end

      it 'parses an addition of constants' do
        expect(parser.parse('1 + 2')).to eq(
          described_class::AdditionExpression.new(
            described_class::ConstantExpression.new(1),
            described_class::ConstantExpression.new(2)
          )
        )
      end

      it 'parses a reference' do
        expect(parser.parse('a')).to eq(
          described_class::ReferenceExpression.new('a')
        )
      end

      it 'parses an addition of references' do
        expect(parser.parse('a + b')).to eq(
          described_class::AdditionExpression.new(
            described_class::ReferenceExpression.new('a'),
            described_class::ReferenceExpression.new('b')
          )
        )
      end

      it 'parses an string of additions' do
        expect(parser.parse('1 + a + 2 + b')).to eq(
          described_class::AdditionExpression.new(
            described_class::ConstantExpression.new(1),
            described_class::AdditionExpression.new(
              described_class::ReferenceExpression.new('a'),
              described_class::AdditionExpression.new(
                described_class::ConstantExpression.new(2),
                described_class::ReferenceExpression.new('b')
              )
            )
          )
        )
      end

      it 'parses a multiplication' do
        expect(parser.parse('1 * a')).to eq(
          described_class::MultiplicationExpression.new(
            described_class::ConstantExpression.new(1),
            described_class::ReferenceExpression.new('a')
          )
        )
      end

      it 'parses mixed addition and multiplication with multiplication having higher precedence' do
        expect(parser.parse('1 + a * b + 2')).to eq(
          described_class::AdditionExpression.new(
            described_class::ConstantExpression.new(1),
            described_class::AdditionExpression.new(
              described_class::MultiplicationExpression.new(
                described_class::ReferenceExpression.new('a'),
                described_class::ReferenceExpression.new('b')
              ),
              described_class::ConstantExpression.new(2)
            )
          )
        )
      end

      it 'parses mixed subtraction and division with division having higher precedence' do
        expect(parser.parse('1 - a / b - 2')).to eq(
          described_class::SubtractionExpression.new(
            described_class::ConstantExpression.new(1),
            described_class::SubtractionExpression.new(
              described_class::DivisionExpression.new(
                described_class::ReferenceExpression.new('a'),
                described_class::ReferenceExpression.new('b')
              ),
              described_class::ConstantExpression.new(2)
            )
          )
        )
      end

      it 'parses parenthesized expressions' do
        expect(parser.parse('(1 + 2) * 3')).to eq(
          described_class::MultiplicationExpression.new(
            described_class::AdditionExpression.new(
              described_class::ConstantExpression.new(1),
              described_class::ConstantExpression.new(2)
            ),
            described_class::ConstantExpression.new(3)
          )
        )
      end

      it 'parses unary minus' do
        expect(parser.parse('-1')).to eq(
          described_class::ConstantExpression.new(-1)
        )
      end

      it 'parses unary minus in an expression' do
        expect(parser.parse('2 * -1')).to eq(
          described_class::MultiplicationExpression.new(
            described_class::ConstantExpression.new(2),
            described_class::ConstantExpression.new(-1)
          )
        )
      end

      it 'rewrites unary minus of a reference to a multiplication with -1' do
        expect(parser.parse('-a')).to eq(
          described_class::MultiplicationExpression.new(
            described_class::ConstantExpression.new(-1),
            described_class::ReferenceExpression.new('a')
          )
        )
      end

      context 'returns a compiled expression that' do
        it 'can describe itself' do
          expect(parser.parse('1 + (2 * (a - b) - c * -5)').to_s).to eq('(1 + ((2 * (a - b)) - (c * -5)))')
          expect(parser.parse(parser.parse('1 + (2 * (a - b) - c * -5)').to_s).to_s).to eq('(1 + ((2 * (a - b)) - (c * -5)))')
        end

        it 'can calculate its own value' do
          expect(parser.parse('1 + 2 + 3 + 4').calculate).to eq(1 + 2 + 3 + 4)
        end

        context 'when containing references' do
          it 'can return those references\' names' do
            expect(parser.parse('a + b * c + d + 4').references).to eq([:a, :b, :c, :d])
          end

          context 'and some references occur more than once' do
            it 'can return the unique references' do
              expect(parser.parse('a + a + a * b').references).to eq([:a, :b])
            end  
          end

          context 'and is given bindings' do
            it 'can calculate its own value' do
              expect(parser.parse('a + b + 3 + 4').calculate(a: 1, b: 2)).to eq(1 + 2 + 3 + 4)
            end

            context 'but not all references are present in the bindings' do
              it 'raises an error' do
                expect { parser.parse('a + b').calculate(a: 1) }.to raise_error(ReferenceError, 'No binding for "b"')
              end
            end
          end
        end

        it 'can be interpreted with a custom interpreter' do
          expect(parser.parse('a + b + 3').accept(TreeBuilder.new)).to eq(
            {
              :type => :operation,
              :operator => :+,
              :left => {
                :type => :reference,
                :name => :a
              },
              :right => {
                :type => :operation,
                :operator => :+,
                :left => {
                  :type => :reference,
                  :name => :b
                },
                :right => {
                  :type => :constant,
                  :value => 3
                }
              }
            }
          )
        end
      end

      context 'when there are trailing tokens' do
        it 'raises an error' do
          expect { parser.parse('a + b a') }.to raise_error(ParseError, 'Trailing tokens after expression')
        end
      end

      context 'when a closing parenthesis is missing' do
        it 'raises an error' do
          expect { parser.parse('(a + (b * c)') }.to raise_error(ParseError, 'Missing closing parenthesis')
        end
      end
    end
  end

  class TreeBuilder
    def visit_constant(constant_expression)
      {
        :type => :constant,
        :value => constant_expression.value
      }
    end

    def visit_reference(reference_expression)
      {
        :type => :reference,
        :name => reference_expression.name
      }
    end

    def visit_operator(operator_expression)
      {
        :type => :operation,
        :operator => operator_expression.operator,
        :left => operator_expression.left.accept(self),
        :right => operator_expression.right.accept(self),
      }
    end
  end
end
