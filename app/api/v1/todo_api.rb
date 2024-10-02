# frozen_string_literal: true

module V1
  class TodoApi < Grape::API
    before { authenticate! }

    resources :todos do
      desc 'GET api/v1/todos'
      params do
        optional :q, type: Hash do
          optional :title_cont
        end
        optional :page, type: Integer, default: 1
        optional :limit, type: Integer, default: 10
      end
      get do
        query = current_user.todos.order(created_at: :desc).ransack(params[:q])
        todos = pagination(query.result)
        todos_serializer = each_serializers(todos)

        render_success(ResponseStatus::SUCCESS, I18n.t('todos.list.success'), todos_serializer)
      end

      desc 'GET api/v1/todos/:id'
      params do
        requires :id, type: Integer, message: I18n.t('todos.id.required')
      end
      get ':id' do
        todo = current_user.todos.find(params[:id])
        todo_serializer = TodoSerializer.new(todo)

        render_success(ResponseStatus::SUCCESS, I18n.t('todos.detail.success'), todo_serializer)
      end

      desc 'POST api/v1/todos'
      params do
        requires :title, type: String, message: I18n.t('todos.title.required')
        requires :description, type: String, message: I18n.t('todos.description.required')
        requires :start_date, type: DateTime, message: I18n.t('todos.start_date.required')
        requires :end_date, type: DateTime, message: I18n.t('todos.end_date.required')
        optional :image_files, type: Array[Rack::Multipart::UploadedFile]
      end
      post do
        todo = current_user.todos.new(params_todo)
        # TODO: Move the validation to the model and use instance methods with included inheritance
        attach_images(todo, params[:image_files])
        todo.save!
        todo_serializer = TodoSerializer.new(todo)

        render_success(ResponseStatus::SUCCESS, I18n.t('todos.create.success'), todo_serializer)
      end

      desc 'PUT api/v1/todos/:id'
      params do
        requires :title, type: String, message: I18n.t('todos.title.required')
        requires :description, type: String, message: I18n.t('todos.description.required')
        requires :start_date, type: DateTime, message: I18n.t('todos.start_date.required')
        requires :end_date, type: DateTime, message: I18n.t('todos.end_date.required')
        optional :image_files, type: Array[Rack::Multipart::UploadedFile]
      end
      put ':id' do
        todo = current_user.todos.find(params[:id])
        # TODO: Move the validation to the model and use instance methods with included inheritance
        attach_images(todo, params[:image_files])
        todo.update!(params_todo)
        todo_serializer = TodoSerializer.new(todo)

        render_success(ResponseStatus::SUCCESS, I18n.t('todos.update.success'), todo_serializer)
      end

      desc 'DELETE api/v1/todos/:id'
      params do
        requires :id, type: Integer, message: I18n.t('todos.id.required')
      end
      delete ':id' do
        todo = current_user.todos.find(params[:id])
        todo.destroy!

        render_success(ResponseStatus::SUCCESS, I18n.t('todos.delete.success'), todo)
      end
    end

    helpers do
      def params_todo
        params.slice(:title, :description, :start_date, :end_date, :user_id)
      end
    end
  end
end
