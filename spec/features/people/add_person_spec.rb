require 'rails_helper'

describe 'Add person:' do
  before do
    login_as_admin
    visit new_person_path
  end

  let(:fill_right) { fill_person_data(gender: 'Female') }
  let(:model)      { Person }

  describe :link_in_flash do
    Given { @person = fill_person_data(gender: 'Female') }

    When  { click_button 'Create Person' }

    Then  { expect(page).to have_link(complex_name(@person).downcase.titleize,
                                  href: person_path(Person.find_by(email: @person.email))) }
  end

  describe 'simple (no student, no teacher)' do

    it_behaves_like :adds_model

    describe 'do not adds person' do
      Given { fill_person_data email: '3322' }

      Then  { expect { click_button 'Create Person' }.not_to change{Person.count} }
      And   { expect(page).to have_selector('.alert-danger') }
    end
  end

  def fill_person_data p={}
    pf = build(:person, p)
    fill_in 'person_telephones_attributes_0_phone', with: pf.telephones.first.phone
    fill_in 'person_spiritual_name'               , with: pf.spiritual_name
    fill_in 'person_name'                         , with: pf.name
    fill_in 'person_middle_name'                  , with: pf.middle_name
    fill_in 'person_surname'                      , with: pf.surname
    fill_in 'person_email'                        , with: pf.email
    fill_in 'person_education'                    , with: pf.education
    fill_in 'person_work'                         , with: pf.work
    fill_in 'person[birthday]'                    , with: (p[:birthday] || '30.05.1984')
    select  (p[:gender] || 'Male').to_s, from: 'person_gender'
    pf
  end
end
