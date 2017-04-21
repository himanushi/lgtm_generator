require 'rails_helper'

RSpec.describe LgtmController, type: :controller do

  describe "GET #convert" do
    it "returns http success" do
      get :convert
      expect(response).to have_http_status(:success)
    end
  end

end
