require 'rails_helper'

describe WorkRequest::Make, use_case: true do
  describe "perform" do
    subject { 
      WorkRequest::Make.perform(
        'perl',
        ['perl',  '-Mbignum=bpi', '-wle', 'print bpi(2000)'],
        {},
      ) 
    }

    it "should be successful" do
      expect(subject).to be_success
    end

    it "should add a work_request to the db" do
      expect{
        subject
      }.to change(WorkRequest, :count).by(1)
    end

    it "should have the correct image in the job definition" do
      use_case = subject
      expect(use_case.work_request.job_definition["spec"]["template"]["spec"]["containers"][0]["image"]).to eq("perl")
    end

    it "should have the correct commands in the job definition" do
      use_case = subject
      expect(
        use_case.work_request.job_definition["spec"]["template"]["spec"]["containers"][0]["command"]
      ).to eq(['perl',  '-Mbignum=bpi', '-wle', 'print bpi(2000)'])
    end
  end

  describe "perform with a complicated shell script (with shebang)" do
    subject { 
      WorkRequest::Make.perform('node:8-alpine', command, {}) 
    }

    let(:command) {
      <<~HEREDOC
      #!/bin/ash
      set -e
      apk update && apk upgrade
      apk add --no-cache bash git openssh groff less python
      wget "s3.amazonaws.com/aws-cli/awscli-bundle.zip" -O "awscli-bundle.zip"
      unzip awscli-bundle.zip
      rm /var/cache/apk/*
      ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
      rm awscli-bundle.zip
      rm -rf awscli-bundle
      HEREDOC
    }

    it "should be successful" do
      use_case = subject
      expect(use_case).to be_success
      work_request = use_case.work_request

      sleep(5) until WorkRequest::QueryStatus.perform(work_request).terminated? 

      expect(
        WorkRequest::QueryStatus.perform(work_request).log
      ).to end_with("You can now run: /usr/local/bin/aws --version\n")
    end
  end

  describe "perform with a simple shell script that has env vars" do
    subject { 
      WorkRequest::Make.perform('node:8-alpine', command, { pablo: "picaso" }) 
    }

    let(:command) {
      <<~HEREDOC
      #!/bin/ash
      echo $pablo
      HEREDOC
    }

    it "should be successful" do
      use_case = subject
      expect(use_case).to be_success
      work_request = use_case.work_request

      sleep(5) until WorkRequest::QueryStatus.perform(work_request).terminated? 

      expect(
        WorkRequest::QueryStatus.perform(work_request).log
      ).to end_with("picaso\n")
    end
  end

  describe "perform with a simple shell script that has an if statement and empty lines" do
    subject { 
      WorkRequest::Make.perform('node:8-alpine', command, {}) 
    }

    let(:command) {
      <<~HEREDOC
      #!/bin/ash
      
      max=10
      for i in `seq 2 $max`
      do
        echo "$i"
      done
      HEREDOC
    }

    it "should be successful" do
      use_case = subject
      expect(use_case).to be_success
      work_request = use_case.work_request

      sleep(5) until WorkRequest::QueryStatus.perform(work_request).terminated? 

      expect(
        WorkRequest::QueryStatus.perform(work_request).log
      ).to end_with("2\n3\n4\n5\n6\n7\n8\n9\n10\n")
    end
  end

  describe "raise exception if the script has no shebang" do
    subject { 
      WorkRequest::Make.perform('node:8-alpine', command, {}) 
    }

    let(:command) {
      <<~HEREDOC
      max=10
      for i in `seq 2 $max`
      do
        echo "$i"
      done
      HEREDOC
    }

    it "should not be successful" do
      expect{ subject }.to raise_error(Employment::Exception::NoShebang)
    end
  end
end
