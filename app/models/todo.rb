# frozen_string_literal: true

# == Schema Information
#
# Table name: todos
#
#  id          :bigint           not null, primary key
#  description :string
#  end_date    :datetime
#  start_date  :datetime
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_todos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Todo < ApplicationRecord
  include ApiCommon

  MAXIMUM_IMAGE_UPLOAD = 5

  belongs_to :user
  has_many_attached :image_files, dependent: :destroy

  validates :image_files,
            limit: {
              max: MAXIMUM_IMAGE_UPLOAD,
              message:
                I18n.t(
                  'todos.images.maximum_upload',
                  total_number: MAXIMUM_IMAGE_UPLOAD
                )
            }
  validates :image_files, content_type: [:png, :jpg, :jpeg]

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description]
  end

  def image_urls
    image_files.map { |image| Rails.application.routes.url_helpers.url_for(image) }
  end
end
