require 'spec_helper'

describe 'Guardian Addresses' do
  stub_authorization!

  before(:each) do
    @student = Factory(:student)
    @guardian = Factory(:guardian)
    @student.guardians << @guardian
    @student.reload
    @country = Factory(:country, :name => "Japan")

    visit student_path(@student) 
    click_link 'new-student-guardian-tab-link'
    wait_until { page.has_content?('Guardians list') } 
  end
  
  context 'new' do 
    it "should add and show address to a student guardian", :js => true do 
      @student.guardians.first.addresses.count.should eql(0)

      find('.show-link').click
      tr_count = page.all('table#student-guardian-addresses-index tr').size 
      click_link 'new-student-guardian-address-link'
      
      wait_until { find('#new-student-guardian-address-form').visible? }
      !page.find('#new-student-guardian-address-link').visible? 
      select 'Japan', :from => 'country_dropdown'
      fill_in 'address_address1', :with => 'Subaru str.'
      fill_in 'address_city', :with => 'Nagoya'
      click_button 'submit-student-guardian-address-button'

      wait_until { !page.find('#new-student-guardian-address-form').visible? }
      page.should have_content('Japan')
      page.should have_content('Nagoya')
      page.should have_content('Subaru str.')
      page.all('table#student-guardian-addresses-index tr').size == tr_count + 1
      within('.student-guardian-addresses-count') { page.should have_content('Addresses list(1)') }
      @student.guardians.first.addresses.count.should  eql(1)
    end

    it 'should cancel adding', :js => true do 
      find('.show-link').click
      click_link 'new-student-guardian-address-link'

      wait_until { find('#new-student-guardian-address-form').visible? }
      click_link 'cancel-student-guardian-address-link'
      wait_until { !page.find('#new-student-guardian-address-form').visible? }
    end 
  end

  context 'edit, delete, set primary' do 
    before do 
      bulgaria = Factory(:country, :name => "Bulgaria")
      address1 = Factory(:address, :address1 => 'Toyota str.', :country => @country, :city => 'Nagoya')
      address2 = Factory(:address, :address1 => 'Maria Luiza bul.', :country => bulgaria, :city => 'Varna')
      @student.guardians.first.addresses << [ address1, address2 ]
      visit student_guardian_path(@student, @student.guardians.first)
    end

    it 'should edit address for student guardian', :js => true do 
      Factory(:country, :name => "Brasil")
      page.should have_content 'Bulgaria'

      within('table#student-guardian-addresses-index tr#address-2') { find('.edit-link').click }
      wait_until { find('#edit-address-modal').visible? }

      select 'Brasil', :from => 'country_dropdown'
      fill_in 'address_address1', :with => 'Rio str.'
      fill_in 'address_city', :with => 'Brasilia'

      click_button 'submit-student-guardian-address-button'
      wait_until { !page.find('#edit-address-modal').visible? }
      page.should have_content 'Brasil'
      page.should_not have_content 'Bulgaria'
    end

    it 'should cancel edit', :js => true do 
      within('table#student-guardian-addresses-index tr#address-2') { find('.edit-link').click }
      wait_until { find('#edit-address-modal').visible? }
      
      click_link 'cancel-student-guardian-address-link'
      wait_until { !page.find('#edit-address-modal').visible? }
    end

    it 'should delete address for student guardian', :js => true do 
      tr_count = page.all('table#student-guardian-addresses-index tr').size
      within('.student-guardian-addresses-count') { page.should have_content('Addresses list(2)') }
      page.should have_content('Bulgaria')
      @student.guardians.first.addresses.size.should eql(2)

      within("table#student-guardian-addresses-index tr#address-#{@student.guardians.first.addresses.last.id}") do 
        find('.delete-link').click
      end
      page.driver.browser.switch_to.alert.accept

      wait_until { page.all('table#student-guardian-addresses-index tr').size == tr_count - 1 } 
      within('.student-guardian-addresses-count') { page.should_not have_content('Addresses list(2)') }
      page.should_not have_content('Bulgaria')
      @student.guardians.first.addresses.size.should eql(1)
    end

 
    it 'should set primary address for student guardian', :js => true do 
      @student.guardians.first.guardian_addresses.first.is_primary? == true
      @student.guardians.first.guardian_addresses.second.is_primary? == false

      within('table#student-guardian-addresses-index tr#address-2') { click_link 'set_primary_link' }

      @student.guardians.first.guardian_addresses.first.is_primary? == false
      @student.guardians.first.guardian_addresses.second.is_primary? == true
    end
  end
  
  
end