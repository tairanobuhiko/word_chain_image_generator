class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  def index
  end

  def create
    words = params[:words]
    filtered_words = WordFilterService.filter_words(words)
    return render json: { error: '画像生成エラー:<br>不適切な単語が含まれています' }, status: 406 if words.length != filtered_words.length

    translated_words = TranslationService.translate(filtered_words.join(','))
    filename = translated_words.clone
    puts filename
    image_bytes, http_status, generate_model = generate_image(translated_words)

    user_id = if user_signed_in?
                current_user.id
              else
                2 # ゲストユーザーを定義
              end

    # DBへ保存
    image_generate = ImageGenerate.new(
      user_id:,
      word_chain: words.join(','),
      prompt: filename,
      http_status:,
      generate_model:
    )

    if http_status == 200
      image_generate.image.attach(io: StringIO.new(image_bytes), filename: "#{filename}.jpg", content_type: 'image/jpeg')
      image_data = Base64.encode64(image_bytes)
      response_body = { image: image_data, filename: }
    else
      response_body = { error: "画像生成エラー：<br>ステータスコード：#{http_status}" }
    end
    image_generate.save!
    image_url = "https://word-chain-image-generator.onrender.com/images/#{image_generate.id}"
    shortened_url = TinyUrlService.shorten(image_url)
    response_body[:image_url] = shortened_url
    render json: response_body, status: (http_status == 200 ? :ok : :internal_server_error)
  end

  def term_of_service
  end

  def privacy_policy
  end

  def maintenance
  end

  private

  def generate_image(translated_words)
    generate_model = 'gpt-image-1.5'
    image_bytes, http_status = GptImageService.query(translated_words)
    [image_bytes, http_status, generate_model]
  end
end
