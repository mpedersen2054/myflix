require 'spec_helper'

describe StripeWrapper::Charge do
  before do
    StripeWrapper.set_api_key
  end
  let(:token) do
    token = Stripe::Token.create(
          :card => {
          :number => card_number,
          :exp_month => 3,
          :exp_year => 2015,
          :cvc => "314"
        },
      ).id
  end

  context "with valid credit card" do
    let(:card_number) { "4242424242424242" }

    it "successfully charges the card", :vcr do
      charge = StripeWrapper::Charge.create(amount: 300, card: token)
      expect(charge).to be_successful
    end
  end

  context "with invalid credit card", :vcr do
    let(:card_number) { "4000000000000002" }
    let(:charge) do
      charge = StripeWrapper::Charge.create(amount: 300, card: token)
    end

    it "does not successfully charge card" do
      expect(charge).not_to be_successful
    end

    it "contains an error message", :vcr do
      expect(charge.error_message).to eq('Your card was declined.')
    end
  end
end
