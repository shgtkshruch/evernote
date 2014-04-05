require_relative '../bundle/ruby/2.1.0/gems/pocket-ruby-0.0.5/lib/pocket' 
require_relative './config'

class SsPocket
  def initialize
    Pocket.configure do |config|
      config.consumer_key = CONSUMERKEY
    end
    @client = Pocket.client(:access_token => ACCESSTOKEN)
  end

  def add(url, tags = '')
    @client.add :url => url, :tags => tags
  end

  def retrieve(count)
    @client.retrieve(:detailType => :simple, :count => count)
  end
end
