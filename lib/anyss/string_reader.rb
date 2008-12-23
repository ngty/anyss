require 'csv'

module Anyss
  class StringReader < DelegateClass(CSV::StringReader) 
    def initialize(obj_to_delegate_to)
      super(obj_to_delegate_to)
    end
  end
end
