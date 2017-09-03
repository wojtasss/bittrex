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
        url = "#{HOST}/#{path}"
        req.params.merge!(params)
        req.url(url)

        if key
          req.params["apikey"]   = key
          req.params["nonce"]    = nonce
          url_for_signature = req.params.empty? ? url : (url + '?' + URI.encode_www_form(req.params))
          req.headers["apisign"] = signature(url_for_signature, nonce)
        end

        puts req.inspect
      end

      JSON.parse(response.body)
    end

    private

    def signature(url, nonce)
      puts url
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), secret.encode('ASCII'), url.encode('ASCII'))
    end

    def connection
      @connection ||= Faraday.new(:url => HOST) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
