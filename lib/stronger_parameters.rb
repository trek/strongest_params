Bundler.require(:default)
require 'active_model'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'set'

class StrongerParameters < ActiveSupport::HashWithIndifferentAccess
  include ActiveModel::Validations

  def self.name
    "StrongerParamters"
  end

  module WhiteListing
    def validate(model)
      model.allowed_params.merge(attributes)
      super
    end
  end

  def self.validates_nested(*attr_names, &block)
    validates_with StrongerParameters::NestedValidator, _merge_attributes(attr_names), &block
  end
  
  class NestedValidator < ActiveModel::EachValidator
    def initialize(options, &block)
      options[:with] ||= Class.new(StrongerParameters, &block)
      super
    end

    def validate_nested(record, attribute, value)
      return if there_is_no_reason_to_validate(value)

      errors = value.is_a?(Array) ? errors_from_array(value) : errors_from_hash(value)
      record.errors.add(attribute, errors) unless errors.empty?
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
    
    private
    def there_is_no_reason_to_validate(value)
      value.nil? && !options[:presence]  
    end

    def errors_from_array(array)
      array.inject([]) do |errors, item|
        nested = options[:with].new(item)
        errors << nested.errors unless nested.valid?
        errors
      end
    end

    def errors_from_hash(hash)
      hash = options[:with].new(hash)
      hash.valid?
      hash.errors
    end
  end

  class InclusionValidator < ActiveModel::Validations::InclusionValidator # :nodoc:
    include WhiteListing
  end

  class LengthValidator < ActiveModel::Validations::LengthValidator # :nodoc:
    include WhiteListing
  end

  class ExclusionValidator < ActiveModel::Validations::ExclusionValidator # :nodoc:
    include WhiteListing
  end 

  class PresenceValidator < ActiveModel::Validations::PresenceValidator # :nodoc:
    include WhiteListing
  end 

  class AllowedValidator < ActiveModel::EachValidator
    def validate(model)
      model.allowed_params.merge(attributes)
    end
  end

  def allowed_params
    @allowed_params ||= Set.new([:controller, :action, :format])
  end

  # Params cannot be set. Not sure what is
  # calling this method
  def []=(key,val)
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

# Copyright (c) 2013, Groupon, Inc.
# All rights reserved. 

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met: 

# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer. 

# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution. 

# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission. 

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
