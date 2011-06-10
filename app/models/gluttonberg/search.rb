module Gluttonberg
  class Search

    # Iterate block/content classes to just load these constants before setting up association with their localization. This is kind of hack for lazyloading
    Gluttonberg::Content::Block.classes.uniq.each do |klass|     
      Gluttonberg.const_get klass.name.demodulize
    end

    # if postgresql and their is not special search engine then index data using texticle for postgresql
    if ActiveRecord::Base.configurations[Rails.env]["adapter"] == "postgresql"
      Rails.configuration.search_models.each do |model , columns|
        model =  eval(model)
        model.index do
          columns.each do |column|
            send(column) 
          end
        end        
      end
    end  
    
  
    # if search engine is provided the use its custom methods
    # otherwise use texticle for postgresql and like queries for mysql
    # opts = {
    #   :sources => [],
    #   :published_only => true,
    #   :per_page => 20,
    #   :page => 1
    # }
    def self.find(query, opts = {} )
      models = {}
      sources = opts[:sources]
      published_only = opts[:published_only].blank? ? true : opts[:published_only]
      per_page = opts[:per_page].blank? ? Gluttonberg::Setting.get_setting("number_of_per_page_items") : opts[:per_page]
      page_num = opts[:page]
      # if sources are provided then only look in sources models. It is only required when user want to search in specified models.
      if sources.blank?
        models = Rails.configuration.search_models
      else
        sources.each do |src|
          models[src] = Rails.configuration.search_models[src]
        end
      end
      
      case self.dbms_name
        when "mysql"
          find_in_mysql(query, page_num , per_page , models , published_only)
        when "postgresql"
          find_in_postgresql(query, page_num , per_page, models , published_only)
      end
    end
  
    def self.find_in_mysql(query, page_num , per_page , models , published_only)
      results = []
      prepared_query = "'%#{query}%'"
      models.each do |model , columns|
        conditions = ""
        columns.each do |col|
          conditions << " OR " unless conditions.blank?
          conditions << " #{col} LIKE #{prepared_query}"
        end
        model =  eval(model) #convert class name from sting to a constant
        if published_only == true && model.respond_to?(:published)
          results << model.published.find(:all , :conditions => conditions )
        else  
          results << model.find(:all , :conditions => conditions )
        end
      end
      results = results.flatten
      results.uniq!
      replace_contents_with_page(results).paginate(:per_page => per_page , :page => page_num )
    end
  
    def self.find_in_postgresql(query, page_num , per_page , models , published_only)
      results = []
      models.each do |model , columns|
        model =  eval(model) #convert class name from sting to a constant
        if published_only == true && model.respond_to?(:published)
          results << model.published.search(query)
        else  
          results << model.search(query )
        end
      end
      results = results.flatten
      results.uniq!
      replace_contents_with_page(results).paginate(:per_page => per_page , :page => page_num )
    end
  
    
    
    private 
      
      def self.dbms_name
        adapter_name = ActiveRecord::Base.configurations[Rails.env]["adapter"]
        if ["mysql2" , "mysql"].include?(adapter_name)
          "mysql"
        elsif adapter_name == "postgresql"
          "postgresql"
        else
          adapter_name.to_s
        end
      end
      
      def self.replace_contents_with_page(results)
        # if it is localized or non locaized class then take return its parent page
        results.each_with_index do |result , index|
            if Gluttonberg::Content::Block.classes.collect{|k| [k.to_s , k.to_s + "Localization"] }.flatten.include?(result.class.name.to_s)
              results[index] = result.parent.page
            elsif Gluttonberg::Content::Block.classes.collect{|k| [k.to_s , k.to_s] }.flatten.include?(result.class.name.to_s)
                results[index] = result.page
            end
        end

        results.uniq
      end
  
  end
end  