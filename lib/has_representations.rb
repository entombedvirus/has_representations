module HasRepresentations
  class UnknownRepresentationError < StandardError; end
  
  module ClassMethods
    def has_representations(reps)
      write_inheritable_attribute(:representations, reps)
      include InstanceMethods
      
      before_save do |obj|
        read_inheritable_attribute(:representations).keys.each {|name| obj.set_representation(name)} 
      end
    end
    
    def representation_field_name_for(name)
      assert_valid_representation_name!(name)
      "#{name}_representation" 
    end
    
    def get_transformer(name)
      assert_valid_representation_name!(name)
      read_inheritable_attribute(:representations)[name]
    end
    
    def assert_valid_representation_name!(name)
      unless read_inheritable_attribute(:representations)[name]
        raise UnknownRepresentationError.new("'%s' is not a known representation for %s" % [name, self.name])
      end
    end
  end
  
  module InstanceMethods
    def set_representation(name)
      self.class.assert_valid_representation_name!(name)
      self.send("#{self.class.representation_field_name_for(name)}=", get_transformer(name).call(self))
    end
    
    def to_representation(name)
      get_transformer(name) && get_transformer(name).call(self)
    end
   
    protected 
    
    def get_transformer(name)
      self.class.get_transformer(name)
    end
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
  end
end