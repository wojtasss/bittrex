require "bittrex/version"

module Faraday
  module NestedParamsEncoder
    class << self
      extend Forwardable
      def_delegators :'Faraday::Utils', :escape, :unescape
    end

    def self.encode(params)
      return nil if params == nil

      if !params.is_a?(Array)
        if !params.respond_to?(:to_hash)
          raise TypeError,
            "Can't convert #{params.class} into Hash."
        end
        params = params.to_hash
        params = params.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
        # Useful default for OAuth and caching.
        # Only to be used for non-Array inputs. Arrays should preserve order.
      end

      # Helper lambda
      to_query = lambda do |parent, value|
        if value.is_a?(Hash)
          value = value.map do |key, val|
            key = escape(key)
            [key, val]
          end
          value.sort!
          buffer = ""
          value.each do |key, val|
            new_parent = "#{parent}%5B#{key}%5D"
            buffer << "#{to_query.call(new_parent, val)}&"
          end
          return buffer.chop
        elsif value.is_a?(Array)
          buffer = ""
          value.each_with_index do |val, i|
            new_parent = "#{parent}%5B%5D"
            buffer << "#{to_query.call(new_parent, val)}&"
          end
          return buffer.chop
        elsif value.nil?
          return parent
        else
          encoded_value = escape(value)
          return "#{parent}=#{encoded_value}"
        end
      end

      # The params have form [['key1', 'value1'], ['key2', 'value2']].
      buffer = ''
      params.each do |parent, value|
        encoded_parent = escape(parent)
        buffer << "#{to_query.call(encoded_parent, value)}&"
      end
      return buffer.chop
    end
  end
end

module Bittrex
  autoload :Market,        'bittrex/market'
  autoload :Client,        'bittrex/client'
  autoload :Configuration, 'bittrex/configuration'
  autoload :Currency,      'bittrex/currency'
  autoload :Deposit,       'bittrex/deposit'
  autoload :Order,         'bittrex/order'
  autoload :Quote,         'bittrex/quote'
  autoload :Summary,       'bittrex/summary'
  autoload :Wallet,        'bittrex/wallet'
  autoload :Withdrawl,     'bittrex/withdrawl'

  def self.client
    @client ||= Client.new(configuration.auth)
  end

  def self.config
    yield configuration
    @client = Client.new(configuration.auth)
  end

  def self.configuration
    Configuration.instance
  end

  def self.root
    File.expand_path('../..', __FILE__)
  end
end
