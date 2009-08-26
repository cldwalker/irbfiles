module UrlCheck
  def self.included(mod)
    require 'net/http'
    require 'redirect_follower'
  end

  def url_check(urls, options={})
    responses = urls.map {|e| fetch_url(e, options) }
    render responses, :fields=>[:url, :code, :final_url]
    responses
  end

  private
  def fetch_url(url, options={})
    response = OpenStruct.new(:url=>url)
    begin
      if options[:redirect]
        http_response = RedirectFollower.get_response(url, options)
        response.code = http_response.code
        response.final_url = http_response.final_url
      else
        response.code = Net::HTTP.get_response(URI.parse(url)).code
      end
      puts "Fetched #{url} with response: #{response.code}" if options[:verbose]
    rescue Exception
      response.code = 'error'
      response.error = $!
      puts "Fetched #{url} with error: #{$!}" if options[:verbose]
    end
    response
  end
end