module Palmade::HttpService
  module Http
    class HttpError < Palmade::HttpService::Error
      attr_reader :response

      def initialize(msg = nil, response = nil)
        super(msg)
        @response = response
      end

      def http_error?
        true
      end
    end
  end
end
