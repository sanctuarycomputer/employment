require 'rails_helper'

describe WorkRequest::QueryStatus, use_case: true do
  describe "perform" do
    let(:api_key) {
      FactoryBot.create(:api_key)
    }
    subject { 
      WorkRequest::QueryStatus.perform(work_request) 
    }
    let(:work_request) {
      WorkRequest::Make.perform(
        api_key,
        'perl',
        ['perl',  '-Mbignum=bpi', '-wle', 'print bpi(2000)'],
        {},
      ).work_request
    }

    it "should be successful" do
      expect(subject).to be_success
    end

    it "should not make more recordings in less than 5 seconds" do
      WorkRequest::QueryStatus.perform(work_request) 
      WorkRequest::QueryStatus.perform(work_request) 
      WorkRequest::QueryStatus.perform(work_request) 
      expect(work_request.reload.status_queries.keys.count).to be(1)
    end

    it "should record the log" do
      use_case = WorkRequest::Make.perform(
        api_key,
        'perl',
        ['perl',  '-Mbignum=bpi', '-wle', 'print bpi(2000)'],
        {},
      )

      expect(use_case).to be_success
      work_request = use_case.work_request
      sleep(5) until WorkRequest::QueryStatus.perform(work_request).terminated? 

      expect(
        WorkRequest::QueryStatus.perform(work_request).log
      ).to be_present
      expect(
        WorkRequest::QueryStatus.perform(work_request).log
      ).to start_with("3.14")
    end

    it "should fail gracefully" do
      expect{ 
        WorkRequest::QueryStatus.perform(FactoryBot.create(:work_request, api_key: api_key))
      }.to raise_error(Employment::Exception::NoJobExists)
    end

    it "should know its state" do
      expect(subject).to be_waiting
    end
  end
end
