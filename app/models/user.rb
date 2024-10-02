# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  address                :string
#  alternative_number     :string
#  country                :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  locked                 :boolean          default(FALSE)
#  middle_name            :string
#  note                   :string
#  phone_number           :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("staff")
#  state                  :string
#  uid                    :string
#  user_name              :string
#  zipcode                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  include ApiCommon
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  #  :validatable

  has_one_attached :avatar_file

  has_many :authentication_tokens, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :reviews, dependent: :destroy
  enum role: { staff: 1, admin: 2 }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :avatar_file, content_type: [:png, :jpg, :jpeg]

  def self.ransackable_attributes(_auth_object = nil)
    %w[email user_name phone_number address note]
  end

  def avatar_url
    Rails.application.routes.url_helpers.url_for(avatar_file) if avatar_file.attached?
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[authentication_tokens avatar_file_attachment avatar_file_blob refresh_tokens todos]
  end

  def self.from_omniauth(auth)
    return nil unless auth&.provider == 'line' && auth&.uid

    where(uid: auth&.uid).first_or_initialize.tap do |user|
      random_pass = SecureRandom.urlsafe_base64(8)
      user.uid = auth&.uid
      user.provider = auth&.provider
      user.password = random_pass
      user.password_confirmation = random_pass
      user.first_name = auth&.info&.name
      # user.avatar_url = auth&.info&.image
      user.save!(validate: false)
    end
  end
end
