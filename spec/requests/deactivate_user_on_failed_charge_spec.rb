require 'spec_helper'

describe "Deactive user on failed charge" do
  let(:event_data) do
    {
      "id" => "evt_103rjI21IPceA9OdUvcaVBSZ",
      "created" => 1397680860,
      "livemode" => false,
      "type" => "charge.failed",
      "data" => {
        "object" => {
          "id" => "ch_103rjI21IPceA9Ods50ThfF4",
          "object" => "charge",
          "created" => 1397680860,
          "livemode" => false,
          "paid" => false,
          "amount" => 999,
          "currency" => "usd",
          "refunded" => false,
          "card" => {
            "id" => "card_103rjH21IPceA9Odb0GGm6Hx",
            "object" => "card",
            "last4" => "0341",
            "type" => "Visa",
            "exp_month" => 8,
            "exp_year" => 2015,
            "fingerprint" => "pmVegI3If1BZ90GD",
            "customer" => "cus_3r4hO7FXWRFtA3",
            "country" => "US",
            "name" => nil,
            "address_line1" => nil,
            "address_line2" => nil,
            "address_city" => nil,
            "address_state" => nil,
            "address_zip" => nil,
            "address_country" => nil,
            "cvc_check" => "pass",
            "address_line1_check" => nil,
            "address_zip_check" => nil
          },
          "captured" => false,
          "refunds" => [],
          "balance_transaction" => nil,
          "failure_message" => "Your card was declined.",
          "failure_code" => "card_declined",
          "amount_refunded" => 0,
          "customer" => "cus_3r4hO7FXWRFtA3",
          "invoice" => nil,
          "description" => "failed payment",
          "dispute" => nil,
          "metadata" => {},
          "statement_description" => nil
        }
      },
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => "iar_3rjIjSJyMp6uZL"
    }
  end

  it "deactives a user with the webhook data from stripe for charge failed", :vcr do
    tom = Fabricate(:user, customer_token: "cus_3r4hO7FXWRFtA3")
    post "/stripe_events", event_data
    expect(tom.reload).not_to be_active
  end
end
