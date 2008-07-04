$LOAD_PATH.unshift 'lib/'

begin
  require 'rubygems'
  gem 'mocha', '>= 0.4.0'
  require 'mocha'
  gem 'test-spec'
  require 'test/spec'
  require 'active_support'
rescue LoadError
  puts '=> has_representations tests depend on the following gems: mocha (0.4.0+), test-spec and rails.'
end

begin
  require 'redgreen'
rescue LoadError
  nil
end

Test::Spec::Should.send    :alias_method, :have, :be
Test::Spec::ShouldNot.send :alias_method, :have, :be

# ActiveRecord::Base.disconnect!

require 'has_representations'
Object.send :include, HasRepresentations

# Fake out ActiveRecord so that we can conduct our testing in peace.
class Action 
  attr_accessor :actor_id, :actee_id, :action, :news_feed_representation, :mini_feed_representation

  def initialize(attributes = {})
    attributes.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  %w(before_save after_destroy).each do |callback|
    eval <<-"end_eval"
      def self.#{callback}(&block)
        @#{callback}_callbacks ||= []
        @#{callback}_callbacks << block if block_given?
        @#{callback}_callbacks
      end
    end_eval
  end
end