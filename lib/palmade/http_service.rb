HTTP_SERVICE_LIB_DIR = File.expand_path('..', __FILE__)
HTTP_SERVICE_ROOT_DIR = File.expand_path('../../..', __FILE__)

module Palmade
  module HttpService
    def self.logger; @logger; end
    def self.logger=(l); @logger = l; end

    autoload :Http, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/http')
    autoload :Service, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/service')
    autoload :ServiceResponse, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/service_response')
    autoload :ServiceError, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/service_error')

    autoload :Base, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/base')

    autoload :Utils, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/utils')
    autoload :Patches, File.join(HTTP_SERVICE_LIB_DIR, 'http_service/patches')

    class Error < StandardError; end
  end
end
