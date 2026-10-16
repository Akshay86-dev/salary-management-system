# Custom Devise failure app that returns JSON 401 for API requests
# instead of HTML redirects
class CustomFailure < Devise::FailureApp
  # Respond to JSON requests with 401 and message
  def respond
    json_error
  end

  private

  def json_error
    self.status = :unauthorized
    self.content_type = :json
    self.response_body = { error: "You are not authorized." }.to_json
  end
end
