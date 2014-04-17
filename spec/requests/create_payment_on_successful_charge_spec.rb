require 'spec_helper'

describe "Create payment on successful charge" do
  let(:event_data) do
    {
      "id" => "evt_103r1k21IPceA9OdElMB4ZYB",
      "created" => 1397518868,
      "livemode" => false,
      "type" => "charge.succeeded",
      "data" => {
        "object" => {
          "id" => "ch_103r1k21IPceA9OdukmOC2y1",
          "object" => "charge",
          "created" => 1397518868,
          "livemode" => false,
          "paid" => true,
          "amount" => 999,
          "currency" => "usd",
          "refunded" => false,
          "card" => {
            "id" => "card_103r1k21IPceA9OdPErN01SJ",
            "object" => "card",
            "last4" => "4242",
            "type" => "Visa",
            "exp_month" => 8,
            "exp_year" => 2014,
            "fingerprint" => "V0X3qM8AG1jhlTrq",
            "customer" => "cus_3r1k8dfdBzY1Aa",
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
          "captured" => true,
          "refunds" => [],
          "balance_transaction" => "txn_103r1k21IPceA9OdGODZLDzD",
          "failure_message" => nil,
          "failure_code" => nil,
          "amount_refunded" => 0,
          "customer" => "cus_3r1k8dfdBzY1Aa",
          "invoice" => "in_103r1k21IPceA9Odt5MydzZS",
          "description" => nil,
          "dispute" => nil,
          "metadata" => {},
          "statement_description" => nil
        }
      },
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => "iar_3r1kXFUakSzAEl"
    }
  end
  it "creates a payment with the webhook from stripe for charge succeeded", :vcr do
    post "/stripe_events", event_data
    expect(Payment.count).to eq(1)
  end

  it "creates the payment associated with the user", :vcr do
    tom = Fabricate(:user, customer_token: "cus_3r1k8dfdBzY1Aa")
    post "/stripe_events", event_data
    expect(Payment.first.user).to eq(tom)
  end

  it "creates the payment with the amount", :vcr do
    tom = Fabricate(:user, customer_token: "cus_3r1k8dfdBzY1Aa")
    post "/stripe_events", event_data
    expect(Payment.first.amount).to eq(999)
  end

  it "creates the payment with the reference id", :vcr do
    tom = Fabricate(:user, customer_token: "cus_3r1k8dfdBzY1Aa")
    post "/stripe_events", event_data
    expect(Payment.first.reference_id).to eq("ch_103r1k21IPceA9OdukmOC2y1")
  end
end
