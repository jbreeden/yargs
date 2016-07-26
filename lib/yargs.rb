# Simple argument parser for Ruby.
#
# Description:
#
# - Does NOT bark about unexpected arguments. That's your problem.
# - Always checks for the first value of the flag/value from left to right.
# - Can check for the same flag/value multiple times.
# - Flags & values may be prefixed with '-' or '--', no matter the name
# - Values can be separated by their field name by whitespace OR an '=' sign, but not both
# - Does not modify the argv passed in.
#
# Usage:
#
# ```Ruby
# yargs = Yargs.new(ARGV)
#
# # Check a flag [ie: an arg prefixed with '-' or '--', that has no value]
# flag_given = yargs.flag(:f, :fetch)
# do_something if flag_given
#
# # Get a value [ie: an arg prefixed with '-' or '--' followed by (spaces OR an '=') and the value ]
# start_interval = yargs.value(:i, :interval)
# do_something if start_interval != nil
#
# # Since we're consuming, we could check for interval again
# # (In RL, I'd give them different names, but you get the idea)
# end_interval = yargs.value(:i, :interval)
# do_something if end_interval != nil
# ```

require 'yargs/version'

# # Maybe?
#
# options = Yargs.parse {
#   flag :h, :help {
#
#   }
#
#   value :h, :host { |host|
#
#   }
# }

class Yargs
  # mode argument is deprecated & unused
  def initialize(argv, mode=nil)
    @argv = argv.dup
    @remaining = @argv.dup
  end

  def argv
    @argv
  end

  def remaining
    @remaining
  end

  # Was the flag (option with no value) provided?
  def flag(*names)
    names_alt = "(?:#{names.join('|')})"
    @remaining.dup.each do |arg|
      if /^(-){1,2}#{names_alt}$/ === arg
        @remaining.delete(arg)
        return true
      end
    end
    return false
  end
  alias flag? flag

  # What value was provided for this option?
  # Returns an empty string (indicating a provided option with no value) if
  #   - The option is provided with an equal sign but no value: `--value=`
  # Returns nil (indicating that the option wasn't provided, or looked like a flag) if
  #   - The options simply isn't present in the argv
  #   - There is no following argument:
  #        yargs = Yargs.new(%w[--last-arg])
  #        yargs.value('last-arg') #=> nil
  #        yargs.flag('last-arg') #=> true
  def value(*names)
    name_regex = "(?:#{names.join('|')})"

    @remaining.dup.each_with_index do |arg, index|
      if /^(?:-{1,2})(?:#{name_regex})(=?)(.*)/ === arg
        if !$1.empty?
          @remaining.delete_at(index)
          return $2
        elsif (index + 1) < @remaining.length
          val =  @remaining[index + 1]
          @remaining.delete_at(index + 1)
          @remaining.delete_at(index)
          return val
        end
      end
    end

    return nil
  end
end
