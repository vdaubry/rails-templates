module Builders
  class CreateUser
    def initialize(params:)
      @params = params
      @callback = Callback.new
    end

    def create
      yield callback if block_given?

      self.params = params.merge(
        token: SecureRandom.hex(8),
        refresh_token: SecureRandom.hex(8)
      )
      user = User.new(params)

      if user.save
        callback.success(user)
      else
        callback.failure(user)
      end
    end

    private
    attr_reader :callback
    attr_accessor :params
  end
end
