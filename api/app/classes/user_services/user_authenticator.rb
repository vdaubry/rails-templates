module UserServices
  class UserAuthenticator
    def initialize(email:, password:)
      @email = email
      @password = password
      @callback = Callback.new
    end

    def authenticate
      yield callback if block_given?

      user = User.where(email: email.try(:downcase)).first
      return callback.on_failure.try(:call) unless user && user.authenticate(password)

      callback.on_success.try(:call, user)
    end

    private
    attr_reader :callback, :email, :password
  end
end
