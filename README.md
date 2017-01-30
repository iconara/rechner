# Rechner

This is a toy calculator.

## Usage

It can calculate simple arithmetic expressions:

```ruby
require 'rechner'

Rechner.calculate('1 + 2 + 3') # => 6
Rechner.calculate('2 * (7 - 3)') # => 8
Rechner.calculate('8 / 2 - 4') # => 0
```

It handles references and lets you bind values to them:

```ruby
require 'rechner'

Rechner.calculate('a + b + 3', a: 1, b: 2) # => 6
Rechner.calculate('a * (b - 3)', a: 2, b: 7) # => 8
Rechner.calculate('a / b - 4', a: 8, b: 2) # => 0
```

It can prepare an expression for reuse:

```ruby
require 'rechner'

expression = Rechner.prepare('a + b + 3')
expression.calculate(a: 1, b: 2) # => 6
expression.calculate(a: 2, b: 3) # => 8
```

It can tell you what references an expression contains:

```ruby
require 'rechner'

expression = Rechner.prepare('a + b + 3')
expression.references # => [:a, :b]
```

You can even write your own interpreter for the expressions:

```ruby
require 'rechner'

class Lispify
  def visit_constant(constant_expression)
    constant_expression.value
  end

  def visit_reference(reference_expression)
    reference_expression.name
  end

  def visit_operator(operator_expression)
    format('(%s %s %s)', operator_expression.operator, operator_expression.left, operator_expression.right)
  end
end

expression = Rechner.parse('a + b + 3')
expression.accept(Lispify.new) # => "(+ a (b + 3))"
```

Finally, if your Ruby supports named arguments you can compile the expression to native code:

```ruby
require 'rechner'

expression = Rechner.compile('a + b + 3')
expression.calculate(a: 1, b: 2) # => 6
```

What happens behind the scenes here is that the expression is rendered as a Ruby expression and compiled to a `Proc` using `Kernel.eval`. The `Proc` has named arguments matching the references in the expression, with default value `nil`. If you leave out a binding you will get `TypeError` since the reference will be `nil`, and if you specify an extra binding you will get `ArgumentError` since there is no such named argument.

## Known issues & limitations

This is a toy calculator. It doesn't have proper error handling. Don't use it.

## License & Copyright

© 2017 Theo Hultberg, see LICENSE.txt (BSD 3-Clause).
