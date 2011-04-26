require 'logger'

module Palmade::HttpService
  class Base
    attr_reader :config
    attr_reader :logger
    attr_reader :http_service

    DEFAULT_API_CONFIG_KEY = 'api'.freeze
    DEFAULT_OAUTH_CONFIG_KEY = 'oauth'.freeze
    DEFAULT_OAUTH_ECHO_CONFIG_KEY = 'oauth_echo'.freeze

    DEFAULT_OPTIONS = { }

    def initialize(config, options = { })
      @options = DEFAULT_OPTIONS.merge(options)
      @logger = @options.delete(:logger) || Logger.new($stdout)

      @config = config
      @http_service = nil
    end

    # override this to provide consumer specific api config.
    #
    def api_config(config)
      config[DEFAULT_API_CONFIG_KEY]
    end

    # override this
    def oauth_config(config)
      config[DEFAULT_OAUTH_CONFIG_KEY]
    end

    # override this
    def oauth_echo_config(config)
      config[DEFAULT_OAUTH_ECHO_CONFIG_KEY]
    end

    def boot!
      api_config = self.api_config(@config)

      unless api_config.nil?
        oauth_config = self.oauth_config(@config)
        oauth_echo_config = self.oauth_echo_config(@config)

        svc_options = { }
        svc_options[:oauth_config] = oauth_config unless oauth_config.nil?
        svc_options[:oauth_echo_config] = oauth_echo_config unless oauth_echo_config.nil?

        @http_service = Palmade::HttpService::Service.new(api_config['server'], logger, svc_options)

        # let's enable log activity if needed
        if api_config.include?('log_activity') && api_config['log_activity']
          @http_service.log_activity = true
        end
      else
        raise "Missing configuration for API service, please check your config files."
      end

      self
    end

    def base_url
      @http_service.base_url
    end

    def get(path, query = nil)
      raise_on_error(@http_service.get_json(path, query))
    end

    def post(path, params = nil, query = nil)
      raise_on_error(@http_service.post_json(path, params, query))
    end

    def put(path, content, query = nil)
      raise_on_error(@http_service.put_json(path, content, query))
    end

    def delete(path, query = nil)
      raise_on_error(@http_service.delete(path, query))
    end

    def reset
      @http_service.reset unless @http_service.nil?
    end

    protected

    def raise_on_error(resp, &block)
      sr = ServiceResponse.new(resp).ok!
      if block_given?
        yield(sr)
      else
        sr
      end
    end
  end
end
