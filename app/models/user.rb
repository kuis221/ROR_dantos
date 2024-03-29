class User < ApplicationRecord
  include Followable

  devise :database_authenticatable, :registerable, :omniauthable, :recoverable, :rememberable, :trackable, :validatable

  has_many :goomps, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :joined_goomps, through: :memberships, class_name: "Goomp", source: :goomp
  has_many :posts_from_joined_goomps, through: :joined_goomps, source: :posts
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :rooms, dependent: :destroy
  has_many :managed_rooms, dependent: :destroy, class_name: "Room", foreign_key: :manager_id
  has_many :messages, dependent: :destroy

  def joined_rooms
    Room.where("user_id = ? OR manager_id = ?", self.id, self.id)
  end

  validates :first_name, :last_name, :picture, :headline, presence: true

  extend FriendlyId
  friendly_id :full_name, use: :slugged

  def is_manager_of? goomp
    goomp.user == self
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def join goomp, token = nil
    membership = Membership.where(user: self, goomp: goomp).first_or_initialize

    if membership.persisted?
      if goomp.user_id == self.id
        # Founder can't unjoin his own group
        return false
      else
        membership.destroy
      end
    else
      if goomp.price > 0
        StripeService.subscribe self, goomp, token
      end

      membership.save
    end
  end

  def self.from_omniauth auth
    authdata = case auth.provider
    when "twitter"
      {
        email: auth.info.email,
        first_name: auth.info.name.split(" ").first,
        picture: auth.info.image.gsub("_normal", ""),
        last_name: auth.info.name.split(" ").last,
        uid: auth.uid,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at,
        username: auth.info.nickname,
        provider: "twitter"
      }
    when "linkedin"
      {
        email: auth.info.email,
        first_name: auth.info.first_name,
        picture: auth.extra.raw_info.pictureUrls.values.last.last,
        last_name: auth.info.last_name,
        uid: auth.uid,
        headline: auth.info.description,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at,
        provider: "linkedin"
      }
    when "facebook"
      {
        email: auth.info.email,
        first_name: auth.info.first_name,
        picture: auth.info.image.gsub("square", "large"),
        last_name: auth.info.last_name,
        uid: auth.uid,
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        expires_at: auth.credentials.expires_at,
        provider: "facebook"
      }
    end

    auth = Authorization.find_by uid: authdata[:uid], provider: authdata[:provider]

    return auth&.user || authdata
  end
end
