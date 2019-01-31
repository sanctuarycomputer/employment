require 'rails_helper'

RSpec.describe Api::V1::WorkRequestsController, type: :controller do
  let(:api_key) {
    FactoryBot.create(:api_key)
  }

  let(:work_request) {
    FactoryBot.create(:work_request, api_key: api_key)
  }

  let(:other_api_key) {
    FactoryBot.create(:api_key)
  }

  describe "index" do
    it "errors without an API key" do
      get :index
      expect(json[:errors][0][:code]).to eq "api.invalid_api_key"
      expect(response.status).to eq 404
    end

    it "works" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      get :index
      expect(json[:data]).to eq [] 
      expect(response.status).to eq 200
    end
  end

  describe "show" do
    it "errors without an API key" do
      get :show, params: { id: 0 }
      expect(json[:errors][0][:code]).to eq "api.invalid_api_key"
      expect(response.status).to eq 404
    end

    it "errors when there's no known work_request" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      get :show, params: { id: 0 }
      expect(json[:errors][0][:code]).to eq "api.not_found"
      expect(response.status).to eq 404
    end

    it "errors when there work request belongs do a different API Key" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = other_api_key.key
      get :show, params: { id: work_request.id }
      expect(json[:errors][0][:code]).to eq "api.invalid_api_key"
      expect(response.status).to eq 404
    end

    it "works" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      post :create, params: { image: 'perl' }
      get :show, params: { id: json[:id] }
      expect(response.status).to eq 200
    end
  end

  describe "create" do
    it "errors without an API key" do
      post :create
      expect(json[:errors][0][:code]).to eq "api.invalid_api_key"
      expect(response.status).to eq 404
    end

    it "works" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      post :create, params: { image: 'perl' }
      expect(json[:id]).to be_present
      expect(response.status).to eq 201
    end

    it "errors when there's no image passed" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      post :create
      expect(json[:errors][0][:code]).to eq "job.no_image"
      expect(response.status).to eq 422
    end

    it "treats non array types as a string command" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      post :create, params: { image: 'perl', command: true }
      expect(json[:errors][0][:code]).to eq "command.no_shebang"
      expect(response.status).to eq 422
    end
  end

  describe "destroy" do
    it "errors without an API key" do
      delete :destroy, params: { id: 0 }
      expect(json[:errors][0][:code]).to eq "api.invalid_api_key"
      expect(response.status).to eq 404
    end

    it "errors when there's no known work_request" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      delete :destroy, params: { id: 0 }
      expect(json[:errors][0][:code]).to eq "api.not_found"
      expect(response.status).to eq 404
    end

    it "errors when there work request belongs do a different API Key" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = other_api_key.key
      delete :destroy, params: { id: work_request.id }
      expect(json[:errors][0][:code]).to eq "api.invalid_api_key"
      expect(response.status).to eq 404
    end

    it "works" do
      request.env["HTTP_X_EMPLOYMENT_API_KEY"] = api_key.key
      post :create, params: { image: 'perl' }
      delete :destroy, params: { id: json[:id] }
      expect(response.status).to eq 200
    end
  end
end
