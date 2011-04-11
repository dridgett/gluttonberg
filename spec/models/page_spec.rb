require 'spec_helper'

describe Gluttonberg::Page do
  
  before(:each) do
      p = Page.create! :name => 'first name', :description_name => 'first body'
  end
  
  
  it "test_saves_versioned_copy" do
      p = Page.create! :name => '2nd name', :description_name => 'first body'
      p.new_record?.should == false 
      p.versions.size.should == 1
      p.version.should == 1
      Page.versioned_class.should == p.versions.first.class
  end
    
  
  it "test_saves_without_revision" do
      p = Page.find_by_name('first name')
      old_versions = p.versions.count

      p.save_without_revision

      p.without_revision do
        p.update_attributes :name => 'changed'
      end

      assert_equal old_versions, p.versions.count
    end
    
    it "test_rollback_with_version_number" do
        p = Page.find_by_name('first name')
                
        p.version.should == 1
        
        p.name = "first name v2"
        p.save
        
        p.version.should == 2
        p.name.should == 'first name v2'

        p.revert_to!(1)
        p.version.should == 1
        p.name.should == 'first name'
        p.versions.size.should == 2
        
        p.revert_to!(2)
        p.version.should == 2
        p.name.should == 'first name v2'
        p.versions.size.should == 2
    end
    
    it "should not cross version limit, at the moment i put it 5" do
        p = Page.find_by_name('first name')
                
        p.version.should == 1
        
        p.name = "first name v2"
        p.save
        
        p.version.should == 2
        p.name.should == 'first name v2'
        
        p.name = "first name v3"
        p.save
        
        p.version.should == 3
        p.name.should == 'first name v3'
        
        p.versions.size.should == 3
        
        p.name = "first name v4"
        p.save
        
        p.version.should == 4
        p.name.should == 'first name v4'
        
        p.versions.size.should == 4
        
        p.name = "first name v5"
        p.save
        
        p.version.should == 5
        p.name.should == 'first name v5'
        
        p.versions.size.should == 5
        
        p.name = "first name v6"
        p.save
        
        p.version.should == 6
        p.name.should == 'first name v6'

        p.versions.size.should == 5
    end
    
    it "test transitions " do
        p = Page.find_by_name('first name')
        
        p.version.should == 1
        
        p.current_state.should == :draft
        
        p.reviewed!
        p.current_state.should == :reviewed
        
        # if state in ignore list then it should not create new version
        p.version.should == 1
    end
    
  
end
