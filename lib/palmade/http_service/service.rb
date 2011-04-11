# -*- coding: utf-8 -*-
# encoding: utf-8

require 'uri'
require 'benchmark'

module Palmade::HttpService
  class Service
    class Response < Palmade::HttpService::Http::Response; end
    class UnsupportedScheme < StandardError; end
    class OAuthError < StandardError; end
    class OAuthEchoError < StandardError; end

    DEFAULT_HEADERS = {
      'Connection' => 'Keep-Alive',
      'Keep-Alive' => '300'
    }

    DEFAULT_OPTIONS = { }

    attr_reader :http
    attr_reader :logger
    attr_reader :headers
    attr_reader :base_url
    attr_reader :base_path
    attr_reader :auth_params
    attr_accessor :charset_encoding
    attr_writer :log_activity

    def log_activity(&block)
      if block_given?
        yield if log_activity?
      else
        !logger.nil? && defined?(@log_activity) && @log_activity
      end
    end
    alias :log_activity? :log_activity

    def initialize(root_url, logger = nil, options = { })
      @options = DEFAULT_OPTIONS.merge(options)

      if root_url.is_a?(URI)
        u = root_url
      else
        u = URI.parse(root_url)
      end

      if [ 443, 80 ].include?(u.port)
        @base_url = "#{u.scheme}://#{u.host}"
      else
        @base_url = "#{u.scheme}://#{u.host}:#{u.port}"
      end
      @base_path = [ nil, "", "/" ].include?(u.path) ? "/" : u.path

      @http = Curl::Easy.new
      @http.ssl_verify_peer = false

      @auth_type = nil
      @auth_credentials = nil
      @auth_params = { }

      @logger = logger
      @headers = DEFAULT_HEADERS.merge({ })

      # using oauth
      @oauth_config = @options[:oauth_config]
      setup_oauth if @oauth_config

      # using oauth echo?
      @oauth_echo_config = @options[:oauth_echo_config]
      setup_oauth_echo if @oauth_echo_config

      # nil by default, unless user specified.
      @charset_encoding = nil
    end

    def get(path, query = nil, io = nil)
      url = File.join(@base_url, @base_path, path)
      url += "?#{query_string(query)}" unless query.nil?

      if log_activity?
        resp = nil
        rt = Benchmark.measure { resp = http_get(url, io) }
        log_response("GET", url, rt, resp) unless resp.nil?
        resp
      else
        http_get(url, io)
      end
    end

    def get_json(path, query = nil)
      resp = get(path, query, nil)
      if resp.success?
        resp.json_read
      else
        resp.raise_http_error
      end
    end

    def post(path, params = nil, query = nil, io = nil)
      url = File.join(@base_url, @base_path, path)
      url += "?#{query_string(query)}" unless query.nil?

      if log_activity?
        resp = nil
        rt = Benchmark.measure { resp = http_post(url, params, io) }
        log_response("POST", url, rt, resp) unless resp.nil?
        resp
      else
        http_post(url, params, io)
      end
    end

    def post_json(path, params = nil, query = nil)
      resp = post(path, params, query, nil)
      if resp.success?
        resp.json_read
      else
        resp.raise_http_error
      end
    end

    def put(path, data, query = nil)
      url = File.join(@base_url, @base_path, path)
      url += "?#{query_string(query)}" unless query.nil?

      if log_activity?
        resp = nil
        rt = Benchmark.measure { resp = http_put(url, data) }
        log_response("PUT", url, rt, resp) unless resp.nil?
        resp
      else
        http_put(url, data)
      end
    end

    def put_json(path, obj, query = nil)
      resp = put(path, obj, query)
      if resp.success?
        resp.json_read
      else
        resp.raise_http_error
      end
    end

    def delete(path, query = nil)
      url = File.join(@base_url, @base_path, path)
      url += "?#{query_string(query)}" unless query.nil?

      if log_activity?
        resp = nil
        rt = Benchmark.measure { resp = http_delete(url) }
        log_response("DELETE", url, rt, resp) unless resp.nil?
        resp
      else
        http_put(url)
      end
    end

    def reset
      http_reset
    end

    def basic_auth(username, password)
      auth(username, password, :basic)
    end

    def oauth_auth(oauth_token, oauth_secret)
      auth(oauth_token, oauth_secret, :oauth)
    end

    # access token given to client
    def oauth_echo_auth(token, secret)
      auth(token, secret, :oauth_echo)
    end

    protected

    def setup_oauth
      @oauth_consumer = create_oauth_consumer(@oauth_config)

      raise OauthError, "OAuth echo @oauth_consumer is nil" if @oauth_consumer.nil?
    end

    def setup_oauth_echo
      @oauth_echo_consumer = create_oauth_consumer(@oauth_echo_config)
      @oauth_echo_auth_verification_url = @oauth_echo_config['auth_verification_url']

      raise OauthEchoError, "OAuth echo @oauth_echo_consumer is nil" if @oauth_echo_consumer.nil?
      raise OAuthEchoError, "OAuth echo @oauth_echo_auth_verification_url is nil" if @oauth_echo_auth_verification_url.nil?
    end

    def create_oauth_consumer(oauth_config)
      ::OAuth::Consumer.new(oauth_config['consumer_key'], oauth_config['consumer_secret'], { :site => oauth_config['options']['site'] })
    end

    def auth(username, password = nil, scheme = :basic)
      case scheme
      when :basic, 'basic'
        @auth_scheme = :basic
        @auth_credentials = [ username, password ]
      when :oauth, 'oauth'
        @auth_scheme = :oauth
        @auth_credentials = [ username, password ]
      when :oauth_echo
        @auth_scheme = scheme
        @auth_credentials = [ username, password ]
      else
        raise UnsupportedScheme, "Unsupported auth scheme. Supports only :basic, :oauth, :oauth_echo now."
      end
    end

    def add_auth_headers!(meth)
      unless @http.headers.include?('Authorization')
        case @auth_scheme
        when :basic
          # ignore, we already added the userpwd combo to @http object,
          # on set
          @http.http_auth_types = :basic or :any
          @http.userpwd = "#{@auth_credentials[0]}:#{@auth_credentials[1]}"
        when :oauth
          raise "OAuth consumer object not set (@oauth_consumer is nil)" if @oauth_consumer.nil?

          oauth_token = ::OAuth::Token.new(@auth_credentials[0], @auth_credentials[1])
          oauth_helper = ::OAuth::Client::Helper.new(@http,
                                                   { :http_method => meth.to_s.upcase,
                                                     :consumer => @oauth_consumer,
                                                     :token => oauth_token,
                                                     :request_uri => @http.url }.merge(@auth_params))
          @http.headers["Authorization"] = auth = oauth_helper.header
        when :oauth_echo
          raise OAuthEchoError, "OAuth echo @oauth_echo_consumer is nil" if @oauth_echo_consumer.nil?
          raise OAuthEchoError, "OAuth echo @oauth_echo_auth_verification_url is nil" if @oauth_echo_auth_verification_url.nil?

          oauth_token = ::OAuth::Token.new(@auth_credentials[0], @auth_credentials[1])

          # mock http request so we could get the correct signature
          # TODO: figure out why using OAuth::Client::Helper doesn't generate the correct signature
          uri = URI.parse(@oauth_echo_auth_verification_url)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri)

          request['Content-Type'] = 'application/x-www-form-urlencoded'
          request.oauth!(http, @oauth_echo_consumer, oauth_token)
          @http.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          @http.headers["X-Verify-Credentials-Authorization"] = request['Authorization']
          @http.headers["X-Auth-Service-Provider"] = @oauth_echo_auth_verification_url

          http = nil
          request = nil
        else
          # ignore
        end
      end
    end

    def prepare_http_for_request!(meth, url, override_headers = { })
      @http.headers = @headers.merge(override_headers)
      @http.url = url.to_s
      add_auth_headers!(meth)
    end

    def http_get(url, io = nil, override_headers = { })
      prepare_http_for_request!('GET', url, override_headers)

      if io.nil?
        @http.http_get
        io = StringIO.new(@http.body_str)
        wrtn = io.size
      else
        wrtn = 0
        @http.on_body { |s| wrtn += io.write(s) }
        @http.http_get
      end
      io.rewind

      Response.new(io, wrtn, @http.response_code, "", @http.header_str)
    end

    def http_head(url, override_headers = { })
      prepare_http_for_request!('HEAD', url, override_headers)

      @http.http_head
      io = StringIO.new(@http.body_str)
      wrtn = io.size
      io.rewind

      Response.new(io, wrtn, @http.response_code, "", @http.header_str)
    end

    def http_post(url, params = nil, io = nil, override_headers = { })
      # Prepare POST parameters/query first, and add the proper
      # Content-Type header for OAuth helper to use when building the
      # signature base
      unless params.nil?
        content_type = nil

        if contains_files?(params)
          @http.multipart_form_post = true

          pb = convert_to_post_fields(params)
        else
          pb = [ convert_to_post_data(params) ]

          unless override_headers.include?('Content-Type')
            if !charset_encoding.nil?
              post_encoding = charset_encoding
              pb[0].force_encoding(Encoding.find(charset_encoding)) if pb[0].respond_to?(:force_encoding)
            elsif pb[0].respond_to?(:encoding)
              post_encoding = pb[0].encoding.name
            else
              post_encoding = 'ISO-8859-1'
            end

            override_headers['Content-Type'] = "application/x-www-form-urlencoded; charset=#{post_encoding}"
          end

          @http.multipart_form_post = false
          @http.post_body = pb[0]
        end
      else
        pb = [ ]
      end

      prepare_http_for_request!('POST', url, override_headers)

      if io.nil?
        @http.http_post(*pb)
        io = StringIO.new(@http.body_str)
        wrtn = io.size
      else
        wrtn = 0
        @http.on_body { |s| wrtn += io.write(s) }
        @http.http_post(*pb)
      end
      io.rewind

      Response.new(io, wrtn, @http.response_code, "", @http.header_str)
    ensure
      @http.multipart_form_post = false
    end

    def http_put(url, data, override_headers = { })
      prepare_http_for_request!('PUT', url, override_headers)

      if data.respond_to?('read')
        req_data = data.read
      else
        req_data = data.to_s
      end

      @http.http_put(req_data)
      io = StringIO.new(@http.body_str)
      wrtn = io.size

      Response.new(io, wrtn, @http.response_code, "", @http.header_str)
    end

    def http_delete(url, override_headers = { })
      prepare_http_for_request!('DELETE', url, override_headers)

      @http.http_delete
      io = StringIO.new(@http.body_str)
      wrtn = io.size

      Response.new(io, wrtn, @http.response_code, "", @http.header_str)
    end

    def http_reset
      @http.reset unless @http.nil?
    end

    def query_string(params, sep = '&')
      Palmade::HttpService::Http.query_string(params, sep)
    end

    def contains_files?(params)
      params.each do |name, value|
        return true if value.kind_of?(File) || value.kind_of?(Tempfile)
      end
      return false
    end

    def convert_to_post_fields(params)
      params.collect do |name, value|
        if value.is_a?(File) || value.is_a?(Tempfile)
          Curl::PostField.file(name.to_s, value.path)
        else
          Curl::PostField.content(name.to_s, value.to_s)
        end
      end
    end

    def convert_to_post_data(params, sep = '&')
      Palmade::HttpService::Http.convert_to_post_data(params, sep)
    end

    def log_response(method, url, rt, resp)
      logger.debug { "  HTTP Service (#{sprintf("%.5f", rt.real)}) #{method} #{url} #{resp.code} (Headers: #{@headers.inspect})" }
    end
  end
end
