module Palmade::HttpService
  module CampoutControllerHelper
    def self.included(base)
      # if this controller, don't respond to logger method,
      # let's try to attach one with the instance we know about.
      unless base.respond_to?(:logger)
        base.class_eval do
          def logger; Palmade::HttpService.logger; end
        end
      end
    end

    def respond(obj)
      yajl_body = Yajl::Encoder.encode(obj)

      if yajl_body.respond_to?(:encoding)
        charset_name = yajl_body.encoding.name
      else
        charset_name = 'UTF-8'
      end

      logger.debug do
        if yajl_body.length > 120
          "  JSON response: %s..." % yajl_body[0,120]
        else
          "  JSON response: %s" % yajl_body
        end
      end

      @headers["Content-Type"] = "application/json; charset=%s" % charset_name
      yajl_body
    end

    def respond_error(msg, code = nil, *attachments)
      respond({ 'error' => {
                  'message' => msg,
                  'code' => code.to_s,
                  'attachments' => attachments
                }})
    end

    def respond_exception(e)
      respond_error(e.message, e.class.name, e.backtrace.join('\n'))
    end
  end
end
