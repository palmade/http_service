module Palmade::HttpService
  module Http
    class Response
      attr_accessor :body, :size, :code, :message
      alias :status :message

      def initialize(body, size, code, message, headers = { })
        @body = body
        @size = size

        @code = code.to_i
        @message = message
        @headers = headers

        if @body.respond_to?(:set_encoding) && !content_charset.nil?
          @body.set_encoding(Encoding.find(content_charset) || 'BINARY')
        end
      end

      def http_response?; true; end

      def headers
        if @headers.is_a?(Hash)
          @headers
        else
          @headers = Palmade::HttpService::Http.parse_header_str(@headers)
        end
      end

      def method_missing(name, *args, &block)
        @body.send(name, *args, &block)
      end

      def raise_http_error
        raise http_error if fail?
      end

      def http_error
        fail? ? HttpError.new("Http failed #{@code} #{@message}", self) : nil
      end

      def success?
        @code == 200
      end
      alias :success :success?

      def fail?
        !success?
      end

      def read
        @body.read
      end

      def json_read
        Palmade::HttpService::Http.json_parse { @body.rewind; @body.read }
      end

      def xml_read(options = { })
        Palmade::HttpService::Http.xml_parse { @body.rewind; @body }
      end

      def to_s
        "HTTP #{@code} #{message}".strip
      end

      def last_modified
        if defined?(@last_modified)
          @last_modified
        else
          if headers.include?('Last-Modified')
            @last_modified = headers['Last-Modified'].to_time
          else
            @last_modified = nil
          end
        end
      end

      def content_length
        if defined?(@content_length)
          @content_length
        else
          if headers.include?('Content-Length')
            if headers['Content-Length'].is_a?(Array)
              @content_length = headers['Content-Length'].first.to_i
            else
              @content_length = headers['Content-Length'].to_i
            end
          else
            @content_length = nil
          end
        end
      end

      def content_type
        if defined?(@content_type)
          @content_type
        else
          if headers.include?('Content-Type')
            @content_type = headers['Content-Type']
          else
            @content_type = nil
          end
        end
      end

      def media_type
        if defined?(@media_type)
          @media_type
        else
          if content_type
            @media_type = content_type.split(/\s*[;,]\s*/, 2).first.downcase
          else
            @media_type = nil
          end
        end
      end

      def media_type_params
        if defined?(@media_type_params)
          @media_type_params
        else
          if content_type
            @media_type_params = content_type.split(/\s*[;,]\s*/)[1..-1].
              collect { |s| s.split('=', 2) }.
              inject({ }) { |hash,(k,v)| hash[k.downcase] = v ; hash }
          else
            @media_type_params = { }
          end
        end
      end

      def content_charset
        if defined?(@content_charset)
          @content_charset
        else
          @content_charset = media_type_params['charset']
        end
      end
    end
  end
end
