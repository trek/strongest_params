## Stronger Parameters

Stronger Parameters is a library intended to replace Rails [strong_parameters](https://github.com/rails/strong_parameters). `strong_parameters` has a nice chainable API for validating input in code at the place the code lives:

```ruby
params.require(:person).permit(:name, :age)
```

but it isn't terribly composable if you want to store validation rules elsewhere.

Stronger Parameters uses [ActiveModel validations](http://api.rubyonrails.org/classes/ActiveModel/Validations.html) internally rather than inventing a new API for data validations. Some possible uses:

Data shape validations for functions, procs, commands, etc (a la [Schema for Clojure](https://github.com/prismatic/schema)):

```ruby
class Rule
  class Schema < StrongerParameters
      validates :name, :age, :color, presence: true
          validates :coolness, allowed: true
            end

              def call(parameters)
                  raise ArgumentError unless Schema.new(parameters).valid?
                      # continue exection
                        end
                        end
                        ```

                        Rails parameters validations at the controller layer:

                        ```
                        class FoosController < ApplicationController
                          class Validations < StrongerParameters
                              validates :name, :age, :color, presence: true, on: [:create, :update]
                                  validates_nested :author do |a|
                                        a.validates :name, length: {minimum: 12}, on: [:create]
                                            end
                                              end
                                              end
                                              ```

## Available validations
### Allowed
Specifies that a parameter is allowed. By defalt, paramters must be whitelisted. Passing unknown paramters will fail.

```ruby
validates :name, allowed: true
```

A parameter can be allowed but not required:

```ruby
validates :name, allowed: true, presence: false
```


### Presence
Specifies that a parameter's presence is required. Parameters will be considred invalid if a required key is missing:

```ruby
validates :name, presence: true
```

### Inclusion

Specifies that a parameter's value must be included in a supplied array. Values other than those supplied in the array will not valid.

```ruby
validates :name, inclusion: ['a', 'b']
```

### Exclusion
Specifies that a parameter's value cannot be included in a supplied array. All values are considered valid except those in the array.

```ruby
validates :name, exclusion: ['a', 'b']
```

### Length
Specifies that a parameter's value must be a certain length. See ActiveModel length validation for all the options.

```ruby
validates :name, length: {minimum: 12}
```

### Nested
Validations rules for a nested key. These rules will only apply if the key is present.

```ruby
validates_nested :page, presence: false do |page|
  page.validates :name, presence: true
  end
  ```

## Adding validations
see http://guides.rubyonrails.org/active_record_validations.html#performing-custom-validations

## Available options for validations
see http://guides.rubyonrails.org/active_record_validations.html#conditional-validation
and http://guides.rubyonrails.org/active_record_validations.html#common-validation-options

