require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets @user variable" do
      get :new
      expect(assigns(:user)).to be_new_record
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "GET show" do
    it_behaves_like "requires sign in" do
      let(:action) { get :show, id: 3 }
    end

    it "sets @user variable" do
      set_current_user
      alice = Fabricate(:user)
      get :show, id: alice.id
      expect(assigns(:user)).to eq(alice)
    end
  end

  describe "POST create" do
    context "successful user signup" do
      it "redirects to the sign_in page" do
        result = double(:sign_up_result, successful?: true)
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end

      it "renders the flash message" do
        result = double(:sign_up_result, successful?: true)
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(flash[:success]).to eq("Thank you for registering with MattFlix. Please sign in now.")
      end
    end

    context "failed user signup" do
      it "renders new template" do
        result = double(:sign_up_result, successful?: false, error_message: "This is an error message")
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to render_template :new
      end

      it "sets the flash message" do
        result = double(:sign_up_result, successful?: false, error_message: "This is an error message")
        UserSignup.any_instance.should_receive(:sign_up).and_return(result)
        post :create, user: Fabricate.attributes_for(:user)
        expect(flash[:danger]).to be_present
      end
    end
  end

  describe "GET new_with_invitation_token" do
    it "renders the new template" do
      invite = Fabricate(:invitation)
      get :new_with_invitation_token, token: invite.token
      expect(response).to render_template :new
    end

    it "sets @user with the recipient's email" do
      invite = Fabricate(:invitation)
      get :new_with_invitation_token, token: invite.token
      expect(assigns(:user).email).to eq(invite.recipient_email)
    end

    it "sets @invitation_token" do
      invite = Fabricate(:invitation)
      get :new_with_invitation_token, token: invite.token
      expect(assigns(:invitation_token)).to eq(invite.token)
    end

    it "redirects to expired token page for invalid tokens" do
      get :new_with_invitation_token, token: 'asdfasf'
      expect(response).to redirect_to expired_token_path
    end
  end
end
