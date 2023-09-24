#!/usr/bin/env ruby

require_relative 'cyberpunk'

if ARGV.size != 1
  puts <<-HELP
Usage: ./check.rb <KEY>

See `originalInputUserMappings.xml` for example keys. Anything that begins with
"IK_" is a valid key, but do not include the "IK_" when running this program.

For example, to see what 'F' is bound to ('IK_F' in the mapping file):
  ./check.rb old F
HELP
  exit 1
end

key = Key.new(ARGV[0])

mappings = UserMappings.new('originalInputUserMappings.xml')
result = mappings.button_map[key]

if result.nil? || result.empty?
  puts "No bindings for '#{key.key}'."
else
  puts "Bindings for '#{key.key}':"
  puts result
end
