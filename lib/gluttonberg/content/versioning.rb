module Gluttonberg
  module Content
    # A mixin which allows for any arbitrary model to have multiple versions. It will 
    # generate the versioning models and add methods for creating, managing and 
    # retrieving different versions of a record.
    
    module Versioning
      # The included hook is used to create a bunch of class ivars we need to
      # store various bits of configuration.
      def self.included(klass)
        klass.class_eval do
          extend  Model::ClassMethods
          include Model::InstanceMethods
          
          class << self; 
            attr_reader :versioned, :versioned_model, :versioned_fields;
          end
          @versioned = false
          @versioned_fields = []
          
          attr_reader :current_version          
        end
      end
      
      # This module gets mixed into the class that includes the versioning module
      module Model
        module ClassMethods
          def is_versioned(&blk)
            # Why yes, this is versioned.
            @versioned = true

            # Create the versioned model for example model is Venue to versioned model will be VenueVersion
            class_name = self.name + "Version"
            table_name = Extlib::Inflection.tableize(class_name)
            # Check to see if the versioning is inside a constant
            target = Kernel
            if class_name.index("::")
              modules = class_name.split("::")
              # Remove the versioning class from the end
              class_name = modules.pop
              # Get each constant in turn
              modules.each { |mod| target = target.const_get(mod) }
            end
            @versioned_model = target.const_set(class_name, DataMapper::Model.new(table_name))
            
            # Add the properties declared in the block, and sprinkle in our own mixins
            @versioned_model.class_eval(&blk)
            @versioned_model.send(:include, ModelVersioning)
            
            # For each property on the versioning model, create an accessor on 
            # the parent model, without over-writing any of the existing methods.
            exclusions = [:id, :created_at]
            versioned_properties = @versioned_model.properties.reject { |p| exclusions.include? p.name }
            versioned_properties.each do |prop|
              # Store a reference to this field so we can strip it from 
              # conditions later on.
              @versioned_fields << prop.name
              # Create the accessor that points to the version
              unless respond_to? prop.name
                class_eval %{
                  def #{prop.name}
                    versioned.#{prop.name}
                  end
                }
              end
            end
            
            # Set up filters on the class to make sure the versioning gets migrated
            self.after_class_method(:auto_migrate!) { @versioned_model.auto_migrate! }
            self.after_class_method(:auto_upgrade!) { @versioned_model.auto_upgrade! }
            #vnumber for original model            
            property :vnumber,             Integer #, :nullable => false
            # Associate the model and it’s versioning
            has(n, :versions, :class_name => self.name + "Version", :parent_key => [:id], :child_key => [:parent_id])
            @versioned_model.belongs_to(:parent, :class_name => self.name, :parent_key => [:parent_key], :child_key => [:id])
            
            # Set up validations for when we update in the presence of a version
            after   :valid?,  :validate_current_version
            after   :save,    :save_current_version
            before  :destroy, :cleanup_versions
            
           
          end
          
          def versioned?
            @versioned
          end
          
          # Returns a new instance of the model, with a version instance 
          # already assigned to it based on the options passed in.
          #
          # The options may also include the attributes for the new model. To 
          # specify attributes for the versioned instance, you can pass them in
          # via an entry with the key :versioned_attributes, e.g.
          #
          #   {:name => "spong", :versioned_attributes => {:name =>"le spong"}}
          
                  
          def new_with_version(opts)
            opts[:vnumber] = 1            
            version_opts = extract_version_conditions(opts)
            v_attr = opts.delete(:versioned_attributes)
            
            unless v_attr.nil?
              v_attr.each do |key , val|
                version_opts[key] = val
              end  
            end            
            new_model = new(opts)             
            new_model.vnumber = 1
            new_model.instance_variable_set(:@current_version, @versioned_model.new(version_opts))
            new_model.versions << new_model.current_version                     
            new_model.attributes = opts
            new_model
          end
          
          # find all records of model including its versions using given options        
          def all_with_version(opts = {})
            version_opts = extract_version_conditions(opts)
            matches = all(opts)
            #matches = all(prefix_versioned_fields(opts))
            matches.each do |match|
              version_opts[:vnumber] = match.vnumber              
              match.load_version(version_opts, false) 
            end
            matches
          end
          
          # find first records of model including its versions using given options        
          def first_with_version(opts = {})
            version_opts = extract_version_conditions(opts)
            v_attr = opts.delete(:versioned_attributes)
            version_opts.merge(v_attr) unless v_attr.nil?            
            #match = first(prefix_versioned_fields(opts))            
            match = first(opts)
            version_opts[:vnumber] = match.vnumber if version_opts[:vnumber].blank?
            attributes = match.attributes
            if match
              match.load_version(version_opts, false)
              match
            end
          end
          
          
          # Returns the current version's filtered attributes that are in original model as well
          def filtered_versioned_attributes(vattributes)
            flag = true
            opts = {}            
              exclusions = [:id, :created_at , :updated_at , :parent_id]  
              orignal = first(:id=>vattributes[:parent_id])
              opts = {}            
                vattributes.each do |key , value|              
                  unless exclusions.include?(key)                                        
                    #flag = false if orignal.attributes[key.to_sym].to_s != value.to_s                    
                    opts[key] = value
                  end
                  flag = (orignal.attributes[:vnumber] == vattributes[:vnumber])
                end              
             return flag, opts 
          end
          
          
          # For fields in the conditons which actually belong to the 
          # version, prefix it with the association name — version in
          # this case.
          def prefix_versioned_fields(conditions)
            @versioned_fields.inject(conditions) do |hash, field|
              if conditions[field]
                hash["versioned.#{field}"] = conditions[field]
                conditions.delete(field)
              end
              hash
            end
          end

          def extract_version_conditions(conditions)
            extractions = {
            #  :updated_at  => conditions.delete(:updated_at),              
            #  :created_at  => conditions.delete(:created_at),                   
              :parent_id  => conditions.delete(:parent_id)              
            }            
            extractions[:vnumber] = conditions.delete(:vnumber)  unless conditions[:vnumber].blank?            
            coerce_version_conditions(extractions)
          end
          
          def coerce_version_conditions(conditions)
            if conditions
              [:parent_id , :vnumber ].inject({}) do |hash, entry|
                if conditions[entry]
                  hash[:"#{entry}"] = case conditions[entry]
                    when Numeric, String then conditions[entry].to_i
                    else conditions[entry].id
                  end
                end
                hash
              end
            else
              {}
            end
          end
          
          private 
          
          def extract_version_opts(opts)
            # Coerce each entry into an integer
            [:updated_at , :created_at , :parent_id].inject({}) do |m, n|
              m[:"#{n}"] = opts.delete(n).to_i if opts[n]
              m
            end
          end          
     
        end
        
        module InstanceMethods
          def versioned?
            self.class.is_versioned?
          end
          
          def load_version(opts = {}, fallback = false)            
            # Convert keys into ids if they are not already
            opts.each { |key, value| opts[key] = value.id unless value.is_a? Numeric }
            # Inject additional conditions, since DataMapper isn't scoping on 
            # collections correctly.
            opts[:parent_id] = self.id
            # Stash the opts so we can use em later
            opts[:vnumber] = self.vnumber if opts[:vnumber].blank?
            # Go and find the latest version 
            @current_version = self.class.versioned_model.first(opts.merge(:order => [:updated_at.desc]))            
          end
          
          # Returns the loaded version, of it it's missing,
          # based on the details stored in the current thread.
          def versioned
            if @current_version
              @current_version
            else
              @version_opts = {} if @version_opts.nil?
              load_version(@version_opts)
              @current_version
            end
          end
          
          # If the record doesn't have a version, this will generate a new one
          def ensure_version!
            unless @current_version
              @version_opts[:vnumber] = versions.length + 1
              @current_version= self.class.versioned_model.new(@version_opts)
              versions << @current_version
            end
          end
          
          # this will generate a new version
          def new_version!(options = {}) 
            options[:vnumber] = versions.length + 1            
            @current_version= self.class.versioned_model.new(options)            
            versions << @current_version
            @current_version
          end
          
          # this will create a new version
          def create_new_version!(options = {}) 
            options[:vnumber] = versions.length + 1
            @current_version= self.class.versioned_model.create(options)     
            versions << @current_version
            @current_version
          end
          
          # find latestversion on the base of recent updated_at record
          def latest_version
            self.versions.first(:order => [:updated_at.desc])
          end
                    
          # update original table data by using current versioned record
          def save_current_version_into_original_table            
            exclusions = [:id, :created_at , :updated_at , :parent_id ]         #, :vnumber 
            opts = {}            
              self.versioned_attributes.each do |key , value|              
                unless exclusions.include?(key)
                  opts[key] = value
                end
              end  
              self.update_attributes(opts)              
          end
          
                                        
          # Returns the current version's attributes
          def versioned_attributes
            @current_version.attributes if @current_version
          end
          
          # Returns the current version's filtered attributes that are in original model as well
          #Fixme : in some cases it does not work properly
          def filtered_versioned_attributes
            flag = true
            opts = {}
            unless @current_version.blank?              
              exclusions = [:id, :created_at , :updated_at , :parent_id ]  #, :vnumber
              orignal = self.get(self.versioned_attributes[:parent_id])
              opts = {}            
                self.versioned_attributes.each do |key , value|              
                  unless exclusions.include?(key)                    
                    flag = false if orignal.attributes[key.to_sym] != value
                    opts[key] = value
                  end
                end  
             end
             return flag, opts 
          end
          
          # Replace the attributes of model with current version's attributes
          def replace_with_version
            flag = true
            opts = {}
            if @current_version
              @current_version.attributes 
              exclusions = [:id, :created_at , :updated_at , :parent_id , :vnumber]                        
                self.versioned_attributes.each do |key , value|              
                  unless exclusions.include?(key)                     
                    if attributes[key.to_sym] != value                      
                      attributes[key.to_sym] = value
                      flag = false
                    end
                  end
                end  
             end
             flag
          end
          
          # Assigns the hash of values passed in to the current version's
          # attributes.
          def versioned_attributes=(new_attributes)
            @current_version.attributes = new_attributes if @current_version
          end
          
          private
          
          # Validates the current_version. If it is invalid, it's errors 
          # are appended to the model's own errors.
          def validate_current_version
            if @current_version
              unless @current_version.valid?
                @current_version.errors.each { |name, error| errors.add(name, error) }
              end
            end
          end
          
          def save_current_version
            if @current_version && @current_version.dirty?
              self.vnumber = @current_version.vnumber
              @current_version.save
            end            
          end
          
          def cleanup_versions
            versions(:parent_id => id).destroy!
          end
        end
      end
      
      # This module is used when dynamically creating the versioning class.
      module ModelVersioning
        # This included hook is used to declare base properties like the id and 
        # to set up associations to the dialect and locale
        def self.included(klass)
          klass.class_eval do
            property :id,         DataMapper::Types::Serial
            property :created_at, Time
            property :updated_at, Time          
            property :vnumber,    Integer      
          end
        end
                
      end
    end # Versioning
  end # Content
end # Gluttonberg
