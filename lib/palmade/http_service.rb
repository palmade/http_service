HTTP_SERVICE_LIB_DIR = File.expand_path('..', __FILE__)
HTTP_SERVICE_ROOT_DIR = File.expand_path('../../..', __FILE__)

module Palmade
  module HttpService
    def self.logger; @logger; end
    def self.logger=(l); @logger = l; end

    autoload :Http,            'palmade/http_service/http'
    autoload :Service,         'palmade/http_service/service'
    autoload :ServiceResponse, 'palmade/http_service/service_response'
    autoload :ServiceError,    'palmade/http_service/service_error'

    autoload :Base,            'palmade/http_service/base'

    autoload :Utils,           'palmade/http_service/utils'
    autoload :Patches,         'palmade/http_service/patches'

    class Error < StandardError; end
  end
end
