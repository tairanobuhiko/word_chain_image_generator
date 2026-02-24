require 'rails_helper'
require 'webmock/rspec'

describe GamesController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
    dummy_b64 = Base64.strict_encode64(File.read('public/images/test_image.jpg'))
    stub_request(:post, ENV.fetch('AZURE_OPENAI_ENDPOINT'))
      .to_return(
        status: 200,
        body: { created: Time.now.to_i, data: [{ b64_json: dummy_b64 }] }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'GET /games' do
    it 'indexアクションにリクエストするとレスポンスが返却される' do
      get games_index_path
      expect(response.status).to eq 200
    end
  end

  describe 'POST /games' do
    it 'createアクションにリクエストするとレスポンスが返却される' do
      words = %W[\u30EA\u30B9 \u30B9\u30A4\u30AB \u30AB\u30A8\u30EB \u30EB\u30D3\u30FC \u30D3\u30FC\u30EB]
      post games_create_path, params: { words:, user_id: @user.id }
      expect(response.status).to eq 200
    end
  end
end
