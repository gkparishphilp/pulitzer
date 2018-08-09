json.extract! article, :slug, :avatar, :title, :subtitle, :description, :publish_at
json.user article.user.to_s
json.url article.url( format: :json )