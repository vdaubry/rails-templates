# Simple callback implementation to store some behavior and invoke it later on
#
# Example:
#
#     def make_http_request
#       callback = Callback.new
#       yield callback
#       callback.before
#       response = Net::HTTP.get(URI('http://www.example.com/'))
#       callback.success(response)
#     rescue => error
#       callback.failure(error)
#     end
#
#     make_http_request do |on|
#       # `on` is the callback here
#       on.before do
#         puts "Request will be sent now"
#       end
#       on.success do |response|
#         puts "Request successful: #{response}"
#       end
#       on.failure do |error|
#         puts "An error occured: #{error.message}"
#       end
#     end
#
class Callback < BasicObject
  def initialize(raise_on_missing: false)
    @callbacks = {}
    @raise_on_missing = raise_on_missing
  end

  def respond_to_missing?(name, include_private = false)
    @callbacks.key?(name)
  end

  define_method :inspect, ::Object.instance_method(:inspect)
  define_method :to_s, ::Object.instance_method(:to_s)

  alias_method :pretty_print, :inspect
  alias_method :object_id, :__id__

  # When a new callback type (e.g. `success`) is used for the first time, its method is defined
  # on the fly on the class, so that it will henceforth exist for all `Callback` objects.
  def method_missing(name, *args, &block)
    ::Callback.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{name}(*args, &block)                                            #  def success(*args, &block)
        if block                                                            #    if block
          @callbacks[:#{name}] = block                                      #      @callbacks[:success] = block
        else                                                                #    else
          callback = @callbacks[:#{name}]                                   #      callback = @callbacks[:success]
          if callback                                                       #      if callback
            callback.call(*args)                                            #        callback.call(*args)
          elsif @raise_on_missing                                           #      elsif @raise_on_missing
            ::Kernel.raise ::NoMethodError, "undefined callback: #{name}"   #        ::Kernel.raise ::NoMethodError, "undefined callback: success"
          end                                                               #      end
        end                                                                 #    end
      end                                                                   #  end
    RUBY
    # Now that the method is defined, we simply call it
    __send__(name, *args, &block)
  end
end
