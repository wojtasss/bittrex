module Bittrex
  class Order
    attr_reader :type, :id, :limit,
                :exchange, :price, :quantity, :remaining,
                :total, :fill, :executed_at, :raw

    def initialize(attrs = {})
      @id = attrs['Id'] || attrs['OrderUuid']
      @type = (attrs['Type'] || attrs['OrderType']).to_s.capitalize
      @exchange = attrs['Exchange']
      @quantity = attrs['Quantity']
      @remaining = attrs['QuantityRemaining']
      @price = attrs['Rate'] || attrs['Price']
      @total = attrs['Total']
      @fill = attrs['FillType']
      @limit = attrs['Limit']
      @commission = attrs['Commission']
      @raw = attrs
      @executed_at = attrs['TimeStamp'].nil? ? nil : Time.parse(attrs['TimeStamp'])
    end

    def self.book(market, type, depth = 50)
      orders = []

      if type.to_sym == :both
        orderbook(market, type.downcase, depth).each_pair do |type, values|
          values.each do |data|
            orders << new(data.merge('Type' => type))
          end
        end
      else
        orderbook(market, type.downcase, depth).each do |data|
          orders << new(data.merge('Type' => type))
        end
      end

      orders
    end

    def self.open
      client.get('market/getopenorders')
    end

    def self.history
      client.get('account/getorderhistory')
    end

    def self.buylimit market, quantity, rate
      client.get("market/buylimit", {
        market: market,
        quantity: quantity,
        rate: rate
        })
    end

    def self.selllimit market, quantity, rate
      client.get("market/buylimit", {
        market: market,
        quantity: quantity,
        rate: rate
        })
    end

    private

    def self.orderbook(market, type, depth)
      client.get('public/getorderbook', {
        market: market,
        type: type,
        depth: depth
      })
    end

    def self.client
      @client ||= Bittrex.client
    end
  end
end
