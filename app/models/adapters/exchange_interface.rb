module Adapters
  class ExchangeInterface
    include AbstractInterface

    def self.test()
      Adapters::ExchangeInterface.api_not_implemented(self)
    end

  end
end