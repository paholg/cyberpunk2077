#!/usr/bin/env ruby

require 'csv'
require_relative 'cyberpunk'

TEMPKEY = 'TMP_'

class Remap
  attr_reader :bindings, :map

  def initialize
    @bindings = UserMappings.new('originalInputUserMappings.xml')

    @map = CSV.read('map.csv')
    # Remove header
    @map.shift
  end

  def rebind
    map.each do |old, new|
      bindings.remap(Key.new(old), Key.new(new))
    end
  end

  def save
    bindings.update_doc!
    bindings.save('inputUserMappings.xml')
  end
end

m = Remap.new
m.rebind
m.save

