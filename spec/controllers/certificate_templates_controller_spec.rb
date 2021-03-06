require 'rails_helper'

describe CertificateTemplatesController do
  describe 'not signed in' do
    Given(:params) { {} }

    context '#index' do
      When { get :index }

      it_behaves_like :not_authenticated
    end

    context '#create' do
      When { post :create, params: params }

      it_behaves_like :not_authenticated
    end

    context '#new' do
      When { get :new }

      it_behaves_like :not_authenticated
    end

    context '#edit' do
      When { get :edit, params: { id: 1 } }

      it_behaves_like :not_authenticated
    end

    context '#update' do
      When { patch :update, params: { id: 1 } }

      it_behaves_like :not_authenticated
    end

    context '#destroy' do
      When { delete :destroy, params: { id: 1 } }

      it_behaves_like :not_authenticated
    end

    context '#markup' do
      When { get :markup, params: { id: 1 } }

      it_behaves_like :not_authenticated
    end

    context '#background' do
      When { get :background, params: { id: 1 } }

      it_behaves_like :not_authenticated
    end

    context '#finish' do
      When { post :finish, params: { id: 1 } }

      it_behaves_like :not_authenticated
    end
  end

  describe 'signed in' do
    Given(:user) { create :person, roles: [create(:role, activities: activities)] }
    Given(:template) { create :certificate_template }

    Given { sign_in user }

    describe 'with valid user' do
      describe 'GET #background' do
        Given(:activities) { ['certificate_template:edit'] }

        Given { expect(controller).to receive(:send_file) { controller.head :ok } }

        When  { get :background, params: { id: template.id } }

        Then  { expect(response.status).to eq(200) }
      end
    end

    describe 'with invalid user' do
      Given(:activities) { ['some:some'] }

      describe 'GET #index' do
        When { get :index }

        it_behaves_like :not_authorized
      end

      describe 'GET #new' do
        When { get :new }

        it_behaves_like :not_authorized
      end

      describe 'GET #edit' do
        When { get :edit, params: { id: template.id } }

        it_behaves_like :not_authorized
      end

      describe 'GET #markup' do
        When { get :markup, params: { id: template.id } }

        it_behaves_like :not_authorized
      end

      describe 'GET #background' do
        Given { expect(controller).not_to receive(:send_file) }

        When  { get :background, params: { id: template.id } }

        it_behaves_like :not_authorized
      end

      describe 'PATCH #finish' do
        Given(:action) do
          patch(
            :finish,
            params: {
              id: template.id,
              certificate_template: {
                fields: {
                  CertificateTemplate::FIELDS.first => {
                    CertificateTemplate::DIMENSIONS.first => 100
                  }
                }
              }
            }
          )
        end

        context 'should not update' do
          Then { expect { action }.not_to change { template.reload.fields } }
        end

        context 'redirects' do
          When { action }

          it_behaves_like :not_authorized
        end
      end

      describe 'POST #create' do
        Given(:action) do
          post(
            :create,
            params: {
              certificate_template: {
                title: 'some',
                background: Rails.root.join('spec/fixtures/150x200.png').open
              }
            }
          )
        end

        context 'should not create' do
          Then { expect { action }.not_to change { CertificateTemplate.count } }
        end

        context 'redirects' do
          When { action }

          it_behaves_like :not_authorized
        end
      end

      describe 'PUT #update' do
        Given(:action) { put :update, params: { id: template.id, certificate_template: { title: 'some' } } }

        context 'should not update' do
          Then { expect { action }.not_to change { template.reload.title } }
        end

        context 'redirects' do
          When { action }

          it_behaves_like :not_authorized
        end
      end

      describe 'DELETE #destroy' do
        Given(:action) { delete :destroy, params: { id: template.id } }

        Given { template }

        context 'should not destroy' do
          Then { expect { action }.not_to change { CertificateTemplate.count } }
        end

        context 'redirects' do
          When { action }

          it_behaves_like :not_authorized
        end
      end
    end
  end
end
