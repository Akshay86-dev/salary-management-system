# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def create
      request.format = :json if request.format.nil?

      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      yield resource if block_given?

      token = generate_jwt_token(resource)
      response.headers['Authorization'] = "Bearer #{token}" unless token.nil?

      render json: {
        message: 'Signed in successfully.',
        data: {
          id: resource.id,
          type: 'user',
          attributes: {
            email: resource.email,
            first_name: resource.first_name,
            last_name: resource.last_name,
            full_name: resource.full_name
          },
          token: token
        }
      }, status: :ok
    end

    def destroy
      token = request.headers['Authorization']&.split(' ', 2)&.last
      
      warden.logout
      
      revoke_jwt_token(token) if token
      
      render json: { message: 'Signed out successfully.' }, status: :ok
    end

    # GET endpoint for login - returns info for API clients
    def new
      render json: {
        message: 'Login endpoint',
        instructions: 'Send POST request with email and password'
      }, status: :ok
    end

    protected

    def after_sign_in_path_for(resource)
      nil
    end

    def after_sign_out_path_for(resource)
      nil
    end

    private

    def generate_jwt_token(resource)
      jwt_secret = ENV.fetch('DEVISE_JWT_SECRET', Rails.application.secret_key_base)
      payload = {
        'sub' => resource.id.to_s,
        'jti' => SecureRandom.uuid,
        'exp' => Time.current.to_i + 86400,
        'scp' => 'user'
      }
      JWT.encode(payload, jwt_secret, 'HS256')
    rescue => e
      Rails.logger.error "JWT encoding error: #{e.message}"
      nil
    end

    def revoke_jwt_token(token)
      return unless token

      begin
        jwt_secret = ENV.fetch('DEVISE_JWT_SECRET', Rails.application.secret_key_base)
        decoded_token = JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })
        jti = decoded_token[0]['jti']
        exp = Time.at(decoded_token[0]['exp'])

        JwtBlacklist.create!(jti: jti, exp: exp)
      rescue JWT::DecodeError => e
        Rails.logger.error "JWT decode error during revocation: #{e.message}"
      rescue => e
        Rails.logger.error "Error during token revocation: #{e.message}"
      end
    end
  end
end
