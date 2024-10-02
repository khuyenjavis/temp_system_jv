# frozen_string_literal: true

if User.first.blank?
  User.create(
    email: 'demo@gmail.com',
    password: 'Zxcv@1234'
  )
end

if User.where(role: :admin).blank?
  User.create(
    email: 'admin@gmail.com',
    password: 'Zxcv@1234',
    role: :admin
  )
end
