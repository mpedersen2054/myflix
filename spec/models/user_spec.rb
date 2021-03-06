require 'spec_helper'

describe User do

  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:reviews) }
  it { should have_many(:queue_items) }

  it_behaves_like "tokenable" do
    let(:object) { Fabricate(:user) }
  end

  describe "#queued_video?" do
    it "returns true when the video is in the user's queue" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      queue_item = Fabricate(:queue_item, user: user, video: video)
      expect(user.queued_video?(video)).to be_true
    end

    it "returns false when the video isn't in the user's queue" do
      user = Fabricate(:user)
      video = Fabricate(:video)
      expect(user.queued_video?(video)).to be_false
    end
  end

  describe "#follows?" do
    it "returns true if the current user has a following relationship with another user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, follower: alice, leader: bob)
      expect(alice.follows?(bob)).to be_true
    end

    it "returns false if the current user does not have a following relationship with another user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      Fabricate(:relationship, follower: bob, leader: alice)
      expect(alice.follows?(bob)).to be_false
    end
  end

  describe "#follow" do
    it "follows another user" do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      alice.follow(bob)
      expect(alice.follows?(bob)).to be_true
    end

    it "does not follow one self" do
      alice = Fabricate(:user)
      alice.follow(alice)
      expect(alice.follows?(alice)).to be_false
    end
  end

  describe "#deactivate!" do
    it "deactivates an active user" do
      alice = Fabricate(:user, active: true)
      alice.deactivate!
      expect(alice).not_to be_active
    end
  end
end
