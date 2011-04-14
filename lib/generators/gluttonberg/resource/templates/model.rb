class <%= class_name %> < ActiveRecord::Base
  
  def title_or_name?
    if attributes.has_key? "name"
      name
    elsif attributes.has_key? "title"
      title
    else
      id
    end
  end
  
end