require 'rails_helper'

describe 'Signing' do
  Given { page.set_rack_session(locale: :uk) }

  describe 'Sign in' do
    Given { create :person, email: 'test@example.com', password: 'password', password_confirmation: 'password' }

    When do
      visit root_path
      fill_in 'person_email', with: 'test@example.com'
      fill_in 'person_password', with: 'password'
      click_button I18n.t('devise.links.sign_in')
    end

    Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.sessions.signed_in')) }
  end

  describe 'Sign Up' do
    When do
      visit new_person_registration_path
      fill_in 'person_email', with: 'test@example.com'
      fill_in 'person_password', with: 'password'
      fill_in 'person_password_confirmation', with: 'password'
      fill_in 'person_spiritual_name', with: 'Adi dasa das'
      fill_in 'person_name', with: 'Vasyl'
      fill_in 'person_middle_name', with: 'Alexovich'
      fill_in 'person_surname', with: 'Mitrofanov'
      fill_in 'person_telephones_attributes_0_phone', with: '380112223344'
      select  'Чоловіча', from: 'person_gender'
      fill_in 'person[birthday]', with: '20.05.1985'
      fill_in 'person_education', with: 'NTUU KPI'
      fill_in 'person_work', with: 'Kyivstar'
      fill_in 'person_emergency_contact', with: 'Krishna'
    end

    describe 'should signup without photo and passport' do
      When { click_button I18n.t('devise.links.sign_up') }

      Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.registrations.signed_up'))}
      And  { expect(page).to have_css('.person-brief') }
    end

    describe 'should signup with photo' do
      When do
        attach_file 'person[photo]', "#{Rails.root}/spec/fixtures/150x200.png"
        click_button I18n.t('devise.links.sign_up')
      end

      describe 'should show flash' do
        Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.registrations.signed_up'))}
      end

      describe 'should direct to crop path' do
        Then { expect(find('h1')).to have_content('crop image') }
      end
    end

    describe 'should signup with passport' do
      When do
        attach_file 'person[passport]', "#{Rails.root}/spec/fixtures/150x200.png"
        click_button I18n.t('devise.links.sign_up')
      end

      describe 'should show flash' do
        Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.registrations.signed_up'))}
      end

      describe 'should show passport image' do
        When { visit '/edit' }

        Then  { expect(find('.form-inputs')).to have_link('Show passport') }
      end
    end
  end

  describe 'Edit' do
    context 'with photo' do
      Given { @person = create :person, :with_photo }
      When  { login_as_user(@person) }
      When  { visit edit_person_registration_path(@person) }

      Then  { expect(find('.form-inputs img')['src']).to have_content("/people/show_photo/standart/#{@person.id}") }
    end

    context 'without photo' do
      Given { @person = create :person }
      When  { login_as_user(@person) }
      When  { visit edit_person_registration_path(@person) }

      describe 'photo should be placeholded' do
        Then  { expect(find('.form-inputs img')['src']).to have_content('/assets/fallback/person/default.png') }
      end

      describe 'should update fields without updating password' do
        When do
          attach_file 'person[photo]', "#{Rails.root}/spec/fixtures/150x200.png"
          fill_in 'person_email', with: 'test@example.com'
          fill_in 'person_spiritual_name', with: 'Adi dasa das'
          fill_in 'person_name', with: 'Vasyl'
          fill_in 'person_middle_name', with: 'Alexovich'
          fill_in 'person_surname', with: 'Mitrofanov'
          fill_in 'person_telephones_attributes_0_phone', with: '380112223344'
          select  'Чоловіча', from: 'person_gender'
          fill_in 'person[birthday]', with: '20.05.1982'
          fill_in 'person_education', with: 'NTUU KPI'
          fill_in 'person_work', with: 'Kyivstar'
          fill_in 'person_emergency_contact', with: 'Krishna'
          fill_in 'person_current_password', with: 'password'
          click_button 'Update'
        end

        describe 'should show flash' do
          Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.registrations.updated')) }
        end

        describe 'should direct to crop path' do
          Then { expect(find('h1')).to have_content('crop image') }
        end

        describe 'should be updated' do
          When { visit edit_person_registration_path(@person) }

          Then { expect(find('.form-inputs img')['src']).to have_content("/people/show_photo/standart/#{@person.id}") }
          And  { expect(find('#person_email')['value']).to have_content('test@example.com') }
          And  { expect(find('#person_spiritual_name')['value']).to have_content('Adi Dasa Das') }
          And  { expect(find('#person_name')['value']).to have_content('Vasyl') }
          And  { expect(find('#person_middle_name')['value']).to have_content('Alexovich') }
          And  { expect(find('#person_surname')['value']).to have_content('Mitrofanov') }
          And  { expect(find('#person_telephones_attributes_0_phone')['value']).to have_content('380112223344') }
          And  { expect(find('#person_education')['value']).to have_content('NTUU KPI') }
          And  { expect(find('#person_work')['value']).to have_content('Kyivstar') }
          And  { expect(find('#person_emergency_contact')['value']).to have_content('Krishna') }
          And  { expect(find('#person_gender')).to have_css('option[selected="selected"]', text: 'Чоловіча') }
          And  { expect(find('#datepicker[name="person[birthday]"]').value).to eq('1982-05-20') }
        end
      end

      describe 'should update password' do
        When do
          fill_in 'person_password', with: 'another_password'
          fill_in 'person_password_confirmation', with: 'another_password'
          fill_in 'person_current_password', with: 'password'
          click_button 'Update'
        end

        describe 'should show flash' do
          Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.registrations.updated')) }
        end

        describe 'should allow new password' do
          When do
            logout(:person)
            visit new_person_session_path
            fill_in 'person_email', with: @person.email
            fill_in 'person_password', with: 'another_password'
            click_button I18n.t('devise.links.sign_in')
          end

          Then { expect(find('.alert-notice')).to have_content(I18n.t('devise.sessions.signed_in')) }
        end
      end
    end
  end

  describe 'forgot email' do
    Given { create :person, email: 'admin@example.com', telephones: [create(:telephone, phone: '1111111111')] }
    Given { create :person, email: 'terminator@test.org', telephones: [create(:telephone, phone: '1111111111'), create(:telephone, phone: '2222222222')] }
    Given { visit remind_email_path }

    describe 'found one email' do
      When do
        fill_in 'phone', with: '2222222222'
        click_button 'Get email'
      end

      Then { expect(find('.found-emails').text).to match(/(\w|\*)+@test\.org/) }
      And  { expect(find('.found-emails').text).not_to match(/(\w|\*)+@example\.com/) }
    end

    describe 'found two emails' do
      subject { find('.found-emails').text }

      When do
        fill_in 'phone', with: '1111111111'
        click_button 'Get email'
      end

      Then { is_expected.to match(/(\w|\*)+@example\.com/) }
      And  { is_expected.to match(/(\w|\*)+@test\.org/) }
    end

    describe 'no email found' do
      When do
        fill_in 'phone', with: '3333333333'
        click_button 'Get email'
      end

      Then { expect(find('.found-emails')).to have_content('The telephone is not registered.') }
    end
  end
end
