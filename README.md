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

It can compile an expression for reuse:

```ruby
require 'rechner'

expression = Rechner.compile('a + b + 3')
expression.calculate(a: 1, b: 2) # => 6
expression.calculate(a: 2, b: 3) # => 8
```

It can tell you what references an expression contains:

```ruby
require 'rechner'

expression = Rechner.compile('a + b + 3')
expression.references # => [:a, :b]
```

You can even write your own interpreter for the expressions:

```ruby
require 'rechner'

class MyInterpreter
  # see the parser tests for details
end

expression = Rechner.compile('a + b + 3')
expression.accept(MyInterpreter.new) # => (some structure built by the custom interpreter)
```

## License & Copyright

© 2017 Theo Hultberg, see LICENSE.txt (BSD 3-Clause).
