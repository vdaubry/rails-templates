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
      if user&.authenticate(password)
        callback.success(user)
      else
        callback.failure
      end
    end

    private
    attr_reader :callback, :email, :password
  end
end
