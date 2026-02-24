require 'httparty'
require 'base64'

class GptImageService
  ENDPOINT = ENV.fetch('AZURE_OPENAI_ENDPOINT')
  HEADERS = {
    'api-key' => ENV.fetch('AZURE_OPENAI_API_KEY'),
    'Content-Type' => 'application/json'
  }.freeze
  TIMEOUT_SECONDS = 120

  def self.query(prompt)
    payload = {
      prompt:,
      n: 1,
      size: '1024x1024',
      quality: 'medium',
      output_format: 'jpeg'
    }

    begin
      response = HTTParty.post(ENDPOINT, body: payload.to_json, headers: HEADERS, timeout: TIMEOUT_SECONDS)
      if response.code == 200
        b64_data = response.parsed_response['data'][0]['b64_json']
        image_bytes = Base64.decode64(b64_data)
        [image_bytes, response.code]
      elsif response.code == 429
        Rails.logger.warn('GPT-Image 1.5 のレート制限に達しました。')
        ['', response.code]
      else
        Rails.logger.error("GPT-Image API error: #{response.code} - #{response.body}")
        ['', response.code]
      end
    rescue Net::ReadTimeout, Net::OpenTimeout, HTTParty::Error => e
      Rails.logger.error("GPT-Image API エラー: #{e.message}")
      ['', 500]
    rescue StandardError => e
      Rails.logger.error("GPT-Image 予期しないエラー: #{e.message}")
      ['', 500]
    end
  end
end
