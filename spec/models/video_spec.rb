require 'spec_helper'

describe Video do

  it { should belong_to(:category) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:reviews) }
  it "returns the reviews in created_at DESC order" do
    video = Fabricate(:video)
    review1 = video.reviews.create(content: "cool movie", rating: 4, created_at: 1.day.ago)
    review2 = video.reviews.create(content: "pool movie", rating: 3, created_at: Time.now)
    expect(video.reviews).to eq([review2, review1])
  end

  describe "rating" do
    it "returns the average rating of the reviews" do
      video = Fabricate(:video)
      review1 = Fabricate(:review, video: video, rating: 1)
      review2 = Fabricate(:review, video: video, rating: 3)
      expect(video.rating).to eq(2)
    end
  end

  describe "search_by_title" do
    let(:futurama) { Fabricate(:video, title: "Futurama", created_at: 1.day.ago) }
    let(:back_to_future) { Fabricate(:video, title: "Back to the Future") }

    it "returns empty array if there is no match" do
      expect(Video.search_by_title("hello")).to eq([])
    end

    it "returns array of one video for an exact match" do
      expect(Video.search_by_title("Futurama")).to eq([futurama])
    end

    it "returns array of one video for a partial match" do
      expect(Video.search_by_title("urama")).to eq([futurama])
    end

    it "returns array of all matches ordered by created_at DESC" do
      expect(Video.search_by_title("Futur")).to eq([back_to_future, futurama])
    end

    it "returns empty array for a search with an empty string" do
      expect(Video.search_by_title("")).to eq([])
    end
  end
end
