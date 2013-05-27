require 'active_model'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'pry'
require 'set'

class Parameters < HashWithIndifferentAccess
  include ActiveModel::Validations

  module WhistListing
    def validate(model)
      model.allowed_params.merge(attributes)
      super
    end
  end

  def self.validates_nested(*attr_names, &block)
    validates_with Parameters::NestedValidator, _merge_attributes(attr_names), &block
  end
  
  class NestedValidator < ActiveModel::EachValidator
    def initialize(options, &block)
      options.merge!(:with => Class.new(Parameters, &block))
      super
    end

    def validate_nested(record, attribute, value)
      params = record[attribute] = options[:with].new(value)

      unless params.valid?
        record.errors.add(attribute, :invalid, options.merge(:value => params))
      end
    end

    def validate_each(record, attribute, value)
      record.allowed_params << attribute
      nested = record[attribute]

      if nested.is_a?(Array)
        nested.each {|n| validate_nested(record, attribute, value)}
      else
        validate_nested(record, attribute, value)
      end
    end
  end

  class InclusionValidator < ActiveModel::Validations::InclusionValidator # :nodoc:
    include WhistListing
  end 

  class PresenceValidator < ActiveModel::Validations::PresenceValidator # :nodoc:
    include WhistListing
  end 

  class AllowedValidator < ActiveModel::EachValidator
    def validate(model)
      model.allowed_params.merge(attributes)
    end
  end

  def allowed_params
    @allowed_params ||= Set.new
  end

  def read_attribute_for_validation(key)
    self[key]
  end

  def whitelist!
    not_allowed = self.keys - allowed_params.collect(&:to_s)
    
    if not_allowed.any?
      not_allowed.each do |k|
        errors.add(k, "is not allowed") 
      end
      return false
    end

    true
  end

  def valid?(context = nil)
    super && whitelist!
  end
end
