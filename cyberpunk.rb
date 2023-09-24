
require 'ox'

class Key
  attr_reader :key

  def initialize(key)
    if key.start_with?('IK_')
      @key = key.sub('IK_', '')
    else
      @key = key
    end
  end

  def to_s
    "IK_#{key}"
  end

  def eql?(other)
    self.key == other.key
  end

  def hash
    to_s.hash
  end
end

class Ox::Element
  def is_button
    attributes[:type] == 'Button'
  end

  def has_binding(key)
    nodes.find do |node|
      node.is_a?(Ox::Element) && node.attributes[:id] == key
    end
  end
end

Button = Struct.new(:name, :keys)

class UserMappings
  class MissingBinding < StandardError
    def initialize(binding)
      super("Tried to remap a binding that does not exist, or tried to remap " \
        "the same binding twice: '#{binding}'")
    end
  end

  class DuplicateError < StandardError
    def initialize(keys)
      keys = keys.map(&:key).join(', ')
      super("Attempting to bind to the following keys, without first binding " \
      "them to something else: #{keys}'")
    end
  end

  class AbilityNotFound < StandardError
    def initialize(ability)
      super("Tried to rebind the ability '#{ability}' that does not seem to " \
        "exist. This is probably an error in the script.")
    end
  end

  class ButtonNotFound < StandardError
    def initialize(key)
      super("Tried to rebind '#{key.key}', but it doesn't seem to be bound to " \
        "anything.")
    end
  end

  attr_reader :doc,
    :buttons,
    :button_map,
    :new_button_map,
    :remap_tracker

  def initialize(file_name)
    @doc = Ox.load_file(file_name)
    initialize_buttons
    initialize_button_map
    @new_button_map = {}
    @remap_tracker = {}
  end

  def initialize_buttons
    @buttons = doc.bindings.nodes.select do |node|
      node.is_a?(Ox::Element) && node.is_button
    end.map do |node|
      name = node.attributes[:name]
      keys = node
        .nodes
        .select { |inner| inner.is_a? Ox::Element }
        .map { |inner| Key.new(inner.attributes[:id]) }
      Button.new(name, keys)
    end
  end

  # button_map is a hash of `key => abilities`
  # where `key` is something like "IK_F"
  # and `abilities` is an array of all the ability names it's bound to.
  def initialize_button_map
    @button_map = {}

    buttons.each do |button|
      button.keys.each do |key|
        if @button_map[key].nil?
          @button_map[key] = []
        end
        @button_map[key].push button.name
      end
    end
  end

  def remap(old, new)
    raise MissingBinding.new(old) unless button_map[old]
    new_button_map[new] = button_map[old]
    button_map.delete(old)
    remap_tracker[old] = new
  end

  def update_doc!
    duplicates = []
    merged_button_map = button_map.merge(new_button_map) do |key, old, new|
      duplicates.push key
    end

    raise DuplicateError.new(duplicates) unless duplicates.empty?
    
    remap_tracker.each do |old, new|
      merged_button_map[new].each do |ability|
        update_doc_one!(ability, old, new)
      end
    end
  end

  def update_doc_one!(ability, old, new)
    ability_element = doc.bindings.nodes.find do |n|
      n.is_a?(Ox::Element) && n.attributes[:name] == ability
    end

    raise AbilityNotFound.new(ability) unless ability_element

    button_element = ability_element.nodes.find do |n|
      n.is_a?(Ox::Element) && n.attributes[:id] == old.to_s
    end
    
    raise ButtonNotFound.new(old) unless button_element

    button_element.attributes[:id] = new.to_s
  end

  def save(file_name)
    xml = Ox.dump(doc)
    File.write(file_name, xml)
  end
end
