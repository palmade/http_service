module Palmade::HttpService
  class ServiceError < Palmade::HttpService::Error
    attr_reader :response

    def initialize(resp)
      super(resp.error_message)

      @response = resp
    end

    def code
      @response.error_code
    end

    def attachments
      @response.error_attachments
    end
  end
end
