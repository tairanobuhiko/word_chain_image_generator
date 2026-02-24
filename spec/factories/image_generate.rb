FactoryBot.define do
  factory :image_generate do
    word_chain { 'リス, スイカ, カエル, ルビー, ビール' }
    prompt { 'squirrel, water melon, flog, ruby, beer' }
    http_status { 200 }
    generate_model { 'gpt-image-1.5' }
    association :user

    after(:build) do |image_generate|
      image_generate.image.attach(io: File.open('public/images/test_image.jpg'), filename: 'test_image.jpg')
    end
  end
end
