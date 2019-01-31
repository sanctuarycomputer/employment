require 'rails_helper'

describe WorkRequest::Cleanup, use_case: true do
  describe "perform" do
    let(:api_key) {
      FactoryBot.create(:api_key)
    }
    it "should be successful" do
      work_request = WorkRequest::Make.perform(
        api_key,
        'perl',
        ['perl',  '-Mbignum=bpi', '-wle', 'print bpi(2000)'],
        {},
      ).work_request

      sleep(2)

      subject = WorkRequest::Cleanup.perform(work_request) 

      expect(subject).to be_success
      expect(subject.work_request.cleaned_up_at).to be_present
    end
  end
end
