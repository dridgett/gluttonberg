class MemberSession < Authlogic::Session::Base
  authenticate_with Gluttonberg::Member
  
  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
  
end