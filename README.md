# BE

# How to run this project

# Cp config/database.yml.example to config/database.yml
# Cp .env.example to .env

# How to build on staging environment
# Please build for env is staging, check at: config/environment/staging.rb
# After run, link swagger at: localhost:3000/swagger

# API LOGGER

## Components:
Contain 4 main files:

- config/initializers/api_log_initializer.rb

- lib/log_wrappers/api_log_wrapper.rb

- lib/middlewares/request_logger_middleware.rb

- config/locales/api_log.en.yml

The `api_log_initializer.rb` is used for intializing variable and log file in log/ folder.

The `api_log_wrapper.rb` is a wrapper that is used for acting as a log wrapper and predefined methods for logging.

The `request_logger_middleware.rb` is a middleware that is used for performing general log for each incoming requests into the server

The `api_log.en.yml` is predefined log messages for specific logics that need to write logs with a more detail content or reasonable messages.

## Usage

### application.rb:

- Must add the middleware and the wrapper in autoload path in application rails:

```
# application.rb

config.autoload_paths << Rails.root.join("lib", "middlewares")
config.autoload_paths << Rails.root.join("lib", "log_wrappers")
```

### api_log_initializer.rb:

You can change the name of log file instead of predefined one `custom_api.log` to meet your demand.

### api_log_wrapper.rb

- You must include the wrapper to use in your code;

- With predefined codes, you can only log with middleware and specific logic log. That's the purpose at the time of implementation. No need to modify anything.

- `@log_data` variable is used to receive data from code block (yield) to write log;

- `write_error_log(log_key, message, options={})` method is used to write a specific error log on your logic code;

- `write_success_log(log_key, message, options={})` method is used to write a specific  success log on your logic code;

- To extend you can write more codes at `process_log(log_data, log_key, options)` (recommend) for more log cases like a third party api request. Or any part of the file.

### request_logger_middleware.rb:

- Requires for performing logging on general incomming request;

- Depending on where you use the middleware, it could provide a different log data on each requests. Please retest when using in your case to make sure everything works fine;

### api_log.en.yml:

- This file is loaded by I18n library. Make sure that rails has I18n loaded in advance;

- Optional to add a new one.

- If a new custom message is adding to the file, it need to follow the structure template

See the file for format detail

## Usecases:

### Grape Api:

**1/ Setup step:**

- Add the `RequestLoggerMiddleware` middleware before the default Grape Logger in your root app api:

Eg:

```
# v1/app_api.rb

insert_before Grape::Middleware::Error, RequestLoggerMiddleware
```

- Create a concern for injecting log method for all sub apis:

```
# api/concerns/grape_api_log_wrapper.rb

require 'api_log_wrapper'

module GrapeApiLogWrapper
  extend ActiveSupport::Concern

  included do
    helpers ::ApiLogWrapper
  end
end
```

Then include the wrapper concern into the root app api:

```
# v1/app_api.rb

include ::GrapeApiLogWrapper
```

**2/ Usage:**

- By default every incoming request to the server will be logged as path with request data in the `RequestLoggerMiddleware` middelware.

- If you wanna add specific log at your sub apis. You can call `write_success_log` or `write_error_log` with proper parameters:

eg:

```
# session_api.rb
# login

 begin
  user = User.find_by(email: params[:email])
  if user&.valid_password?(params[:password]) && !user&.locked
    if user&.locked
      # Add more log if need
      write_error_log("users.login", nil, message_data: {user_info: params[:email]})

      render_error(I18n.t('login.error.ban'), ResponseStatus::UNAUTHORIZED)
    else
      data = user.generate_jwt

      # Add more log if need
      write_success_log("users.login", nil, message_data: {user_info: [user.id, user.email].join(', ')})

      render_success(ResponseStatus::SUCCESS, I18n.t('login.success'), data)
    end
  else
    # Add more log if need
    write_error_log("users.login", nil, message_data: {user_info: params[:email]})

    render_error(I18n.t('login.error.username_password'), ResponseStatus::UNPROCESSABLE_ENTITY)
  end
rescue StandardError => e
  render_error(e.message, ResponseStatus::INTERNAL_SERVER_ERROR)
end
```

