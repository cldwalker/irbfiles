# explained here: http://railstips.org/2009/3/4/following-redirects-with-net-http
# modified version: http://github.com/jnunemaker/columbus/blob/4f5199e2a778563ffc208e314c8879ee13245e6b/lib/columbus/redirect_follower.rb
class RedirectFollower
  class TooManyRedirects < StandardError; end

  attr_accessor :url, :redirect_limit, :response, :redirects, :code, :final_url

  def self.get_response(url, options={})
    new(url, options).resolve
  end

  def initialize(url, options={})
    @url = url
    @redirect_limit = options.delete(:limit) || 5
    @redirects = 0
    @verbose = options[:verbose] || false
  end

  def resolve
    raise TooManyRedirects if redirects >= redirect_limit
    self.response = Net::HTTP.get_response(URI.parse(url))

    if response.kind_of?(Net::HTTPRedirection)
      self.url = redirect_url
      @redirects = @redirects + 1
      puts "redirect #{redirects}: headed to #{url} after receiving #{response.code}" if @verbose
      resolve
    end
    self.final_url = self.url if redirects > 0
    self.code = response.code
    self
  end

  def redirect_url
    if response['location'].nil?
      response.body.match(/<a href=\"([^>]+)\">/i)[1]
    else
      response['location']
    end
  end
end