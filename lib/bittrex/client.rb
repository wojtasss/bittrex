require 'faraday'
require 'base64'
require 'uri'

module Bittrex
  class Client
    HOST = 'https://bittrex.com/api/v1.1'

    attr_reader :key, :secret

    def initialize(attrs = {})
      @key    = attrs[:key]
      @secret = attrs[:secret]
    end

    def get(path, params = {}, headers = {})
      nonce = Time.now.to_i
      response = connection.get do |req|
        url = "#{HOST}/#{path}" + (params.empty? ? "?apikey=#{key}&nonce=#{nonce}" : ("?#{URI.encode_www_form(params)}&apikey=#{key}&nonce=#{nonce}"))
        req.params.merge!(params)
        req.url(url)

        if key
          req.headers["apisign"] = signature(url, nonce)
        end
      end

      JSON.parse(response.body)
    end

    private

    def signature(url, nonce)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), secret, url)
    end

    def connection
      @connection ||= Faraday.new(:url => HOST) do |faraday|
        faraday.request  :url_encoded
        # faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
