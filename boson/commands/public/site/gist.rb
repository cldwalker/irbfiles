# original from http://github.com/defunkt/gist/blob/master/gist.rb
# commit: 595bddc77386b46f30dcae83748d4e2cc9d1b219
module Gist
  def self.included(mod)
    require 'open-uri'
    require 'net/http'
  end

  # @options :private=>:boolean, :string=>:string, :file=>:string
  # @desc gist < file.txt ; echo secret | gist -p ; gist 1234 > something.txt
  def gist(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    if options[:file] || options[:string] || !$stdin.tty?
      string = options[:string] || (options[:file] ? File.read(options[:file]) : $stdin.read)
      Gist.write(string, options)
    else
      puts Gist.read(args.first)
    end
  end

  class << self
    GIST_URL = 'http://gist.github.com/%s.txt'
    @proxy = ENV['http_proxy'] ? URI(ENV['http_proxy']) : nil

    def read(gist_id)
      return open(GIST_URL % gist_id).read unless gist_id.to_i.zero?
      return open(gist_id + '.txt').read if gist_id[/https?:\/\/gist.github.com\/\d+$/]
    end

    def write(content, options)
      url = URI.parse('http://gist.github.com/gists')
      if @proxy
        req = Net::HTTP::Proxy(@proxy.host, @proxy.port).post_form(url, data(nil, nil, content, options[:private]))
      else
        req = Net::HTTP.post_form(url, data(options[:file], nil, content, options[:private]))
      end
      req['Location']
    end

    private
    def data(name, ext, content, private_gist)
      return {
        'file_ext[gistfile1]'      => ext,
        'file_name[gistfile1]'     => name,
        'file_contents[gistfile1]' => content
      }.merge(private_gist ? { 'action_button' => 'private' } : {}).merge(auth)
    end

    def auth
      user  = `git config --global github.user`.strip
      token = `git config --global github.token`.strip
      user.empty? ? {} : { :login => user, :token => token }
    end
  end
end
