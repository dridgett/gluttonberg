module Gluttonberg
  module Content
    # A mixin which provides a super simple publish/approve workflow for a 
    # model. A state machine this is not.
    #
    # The states are :in_progress, :pending, :approved, :rejected
    #
    # For each state there is an instance method for setting and saving that
    # state. There are some additional class methods for retrieving the pending
    # or rejected records.
    module Workflow
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
          
          property :state,  DataMapper::Types::Enum[:in_progress, :pending, :rejected , :approved], :default => :in_progress
        end
      end

      module ClassMethods
        # Returns all records with the pending state. May take additional
        # conditions.
        def all_pending(options = {})
          options[:state] = :pending
          all(options)
        end
        
        # Returns all records with the rejected state. May take additional
        # conditions.
        def all_rejected(options = {})
          options[:state] = :rejected
          all(options)
        end
          
        # Returns all records with the approved state and additionally with the
        # publish flag set. The publish flag is managed by the Publishable mixin,
        # so obviously it need to be included in the model for this method to 
        # work.
        #
        # Extra conditions can also be passed in.
        def all_approved_and_published(options = {})
          options.merge!(:state => :approved , :published => true)
          all(options)  
        end
      end

      module InstanceMethods
        # Sets the state to :pending and saves the record.
        def submit!
          update_attributes(:state => :pending)
        end
        
        # Sets the state to :approved and saves the record.
        def approve!
          update_attributes(:state=>:approved)
        end
        
        # Sets the state to :rejected and saves the record.
        def reject!
          update_attributes(:state=>:rejected)
        end
      end
    end # Workflow
  end # Content
end # Gluttonberg
