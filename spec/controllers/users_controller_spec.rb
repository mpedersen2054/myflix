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
    context "with valid personal info and valid card" do
      let(:charge) { double(:charge, successful?: true) }
      before do
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
      end

      it "creates a user record" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(User.count).to eq(1)
      end

      it "renders the flash message" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(flash[:success]).to eq("Thank you for registering with MattFlix. Please sign in now.")
      end

      it "redirects to the sign_in page" do
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end

      it "makes the user follow the inviter" do
        alice = Fabricate(:user)
        invite = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        post :create, user: { email: 'joe@example.com', password: 'password', full_name: 'Joe Doe' }, invitation_token: invite.token
        joe = User.where(email: 'joe@example.com').first
        expect(joe.follows?(alice)).to be_true
      end

      it "makes the inviter follow the user" do
        alice = Fabricate(:user)
        invite = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        post :create, user: { email: 'joe@example.com', password: 'password', full_name: 'Joe Doe' }, invitation_token: invite.token
        joe = User.where(email: 'joe@example.com').first
        expect(alice.follows?(joe)).to be_true
      end

      it "expires the invitation upon acceptance" do
        alice = Fabricate(:user)
        invite = Fabricate(:invitation, inviter: alice, recipient_email: 'joe@example.com')
        post :create, user: { email: 'joe@example.com', password: 'password', full_name: 'Joe Doe' }, invitation_token: invite.token
        joe = User.where(email: 'joe@example.com').first
        expect(Invitation.first.token).to be_nil
      end
    end

    context "with valid personal info and declined card" do
      it "renders new template" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231231'
        expect(response).to render_template :new
      end

      it "does not create a new user record" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231231'
        expect(User.count).to eq(0)
      end

      it "sets the flash message" do
        charge = double(:charge, successful?: false, error_message: "Your card was declined.")
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '1231231'
        expect(flash[:danger]).to be_present
      end
    end

    context "with invalid personal info" do
      before do
        post :create, user: { email: "mped@example.com", password: "password" }
      end

      it "does not create a user record" do
        expect(User.count).to eq(0)
      end

      it "shows the flash message" do
        expect(flash[:danger]).to be_present
      end

      it "renders the :new template" do
        expect(response).to render_template :new
      end

      it "sets @user variable" do
        expect(assigns(:user)).to be_new_record
        expect(assigns(:user)).to be_instance_of(User)
      end

      it "does not charge the card" do
        StripeWrapper::Charge.should_not_receive(:create)
        post :create, user: { email: "matt@example.com" }
      end

      it "does not send out email with invalid inputs" do
        post :create, user: { email: "matt@example.com" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "sending emails" do
      let(:charge) { double(:charge, successful?: true) }
      after { ActionMailer::Base.deliveries.clear }
      before do
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
      end

      it "sends out email to the user with valid inputs" do
        post :create, user: { email: "matt@example.com", password: "password", full_name: "Matt Peder" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['matt@example.com'])
      end

      it "sends email containing the user's name with valid inputs" do
        post :create, user: { email: "matt@example.com", password: "password", full_name: "Matt Peder" }
        expect(ActionMailer::Base.deliveries.last.body).to include('Matt Peder')
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
