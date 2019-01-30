require 'rails_helper'

RSpec.describe WorkRequest, type: :model do
  it "has valid factory" do
    expect(FactoryBot.build(:work_request)).to be_valid
  end
end
