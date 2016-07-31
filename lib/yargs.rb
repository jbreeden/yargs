=begin
Simple argument parser for Ruby.

 Description:

- Does NOT bark about unexpected arguments. That's your problem.
- Always checks for the first value of the flag/value from left to right.
- Can check for the same flag/value multiple times.
- Flags & values may be prefixed with '-' or '--', no matter the name
- Values can be separated by their field name by whitespace OR an '=' sign, but not both
- Does not modify the argv passed in.

Usage:

```Ruby
yargs = Yargs.new(ARGV)

# Check a flag [ie: an arg prefixed with '-' or '--', that has no value]
flag_given = yargs.flag(:f, :fetch)
do_something if flag_given

# Get a value [ie: an arg prefixed with '-' or '--' followed by (spaces OR an '=') and the value ]
start_interval = yargs.value(:i, :interval)
do_something if start_interval != nil

# We could check for interval again
# (In RL, I'd give them different names, but you get the idea)
end_interval = yargs.value(:i, :interval)
do_something if end_interval != nil
```
=end

require 'yargs/version'

class Yargs
  
  def self.parse(*args, &block)
    yargs = self.new(*args)
    yargs.parse(&block)
  end

  attr_reader :argv, :remaining
    
  # mode argument is deprecated & unused
  def initialize(argv, mode=nil)
    @argv = argv.dup
    @remaining = @argv.dup
    @hit_counts = Hash.new { |h, k| h[k] = 0 }
  end

  # Returns or yields true if a flag was provided with any of the given names.
  def flag(*names)
    result = false
    
    names_alt = "(?:#{names.join('|')})"
    @remaining.dup.each do |arg|
      # TODO: This regex template should be overridable (maximal flexibility and all).
      if /^(-){1,2}#{names_alt}$/ === arg
        @remaining.delete(arg)
        result = true
      end
    end
    
    if block_given? && result
      yield result 
    else
      return result
    end
  end
  alias flag? flag

  # Returns or yields the value given by the provided names.
  # Returns an empty string (indicating a provided option with no value) if
  #   - The option is provided with an equal sign but no value: `--value=`
  # Returns nil (indicating that the option wasn't provided, or looked like a flag) if
  #   - The options simply isn't present in the argv
  #   - There is no following argument:
  #        yargs = Yargs.new(%w[--last-arg])
  #        yargs.value('last-arg') #=> nil
  #        yargs.flag('last-arg') #=> true
  # Returns the provided value in all other cases.
  def value(*names)
    result = nil
    name_regex = "(?:#{names.join('|')})"

    @remaining.dup.each_with_index do |arg, index|
      if /^(?:-{1,2})(?:#{name_regex})(=?)(.*)/ === arg
        if !$1.empty?
          @remaining.delete_at(index)
          result = $2
        elsif (index + 1) < @remaining.length
          val =  @remaining[index + 1]
          @remaining.delete_at(index + 1)
          @remaining.delete_at(index)
          result = val
        end
      end
    end

    if block_given? && result
      yield result
    else
      return result
    end
  end
  
  # Removes the token, and everything after from the remaining argv.
  # Everything that followed the token is returned in an array.
  def everything_after(token)
    post = []
    in_post = false
    
    index = remaining.index(token)
    return post unless index
    post.unshift remaining.pop until remaining.length == index + 1
    remaining.pop # remove the token itself
    post
  end
  
  # Reader friendly way to call instance_eval.
  def parse(&block)
     self.instance_eval(&block) 
  end
end
