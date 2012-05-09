module NanoStore
  module ModelInstanceMethods
    def save(store=nil)
      store ||= self.class.store
      raise NanoStoreError, 'No store provided' unless store

      error_ptr = Pointer.new(:id)
      store.addObject(self, error:error_ptr)
      raise NanoStoreError, error_ptr[0].description if error_ptr[0]
      self
    end
  
    def delete
      nil
    end
    
    def method_missing(method, *args)
      matched = method.to_s.match(/^([^=]+)(=)?$/)
      name = matched[1]
      modifier = matched[2]
      if self.class.attributes.include?(name.to_sym) || name == "_id"
        if modifier == "="
          self.info[name.to_sym] = args[0]
        else
          self.info[name.to_sym]
        end
      else
        super
      end
    end
  end

  module ModelClassMethods
    def attribute(name)
      @attributes << name
    end
    
    def attributes
      @attributes
    end

    def store
      if @store.nil?
        return NanoStore.shared_store 
      end
      @store
    end

    def store=(store)
      @store = store
    end

    def inherited(subclass)
      subclass.instance_variable_set(:@attributes, [])
      subclass.instance_variable_set(:@store, nil)
    end
  end

  class Model < NSFNanoObject
    include ModelInstanceMethods
    extend ModelClassMethods

    def self.new
      self.nanoObject
    end
  end
end