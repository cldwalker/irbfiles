# These tasks create, publish and manage project pages across projects/repositories based on a common project template.
# Since the project template is given a project-specific config, each project page can be customized as needed.
#
# First time setup:
# * git clone git://github.com/cldwalker/irbfiles.git
# * boson install gh_pages/main.rb
# * gem install grancher
# * Customize your ~/.boson/commands/gh_pages/index.rhtml to match your boilerplate. Remember instance variables in the template
#   map directly to keys for your repo config entry.
# * Customize the MyPages module below to fit your needs.
# * If using the rdoc task, install the hanna rdoc template: http://github.com/mislav/hanna/
#
# From a new repo directory:
# * `boson edit` and add an entry for your repo with your appropriate repo-specific config hash.
# * `boson website` to create the repo in website/.
# * Optionally gh_pages:rdoc` to create a hanna-based rdoc under website/.
# * `boson publish` pushes everthing in website/ to your gh-pages branch.
#
# Managing templates: TODO
module Main
  def self.included(mod)
    require 'erb'
  end

  # @options :yardoc=>:boolean
  # Create rdoc with hanna
  def rdoc(*doc_opts)
   options = doc_opts[-1].is_a?(Hash) ? doc_opts.pop : {}
   directory = File.exists?("website") ? 'website/doc' : 'doc'
   FileUtils.rm_r(directory) if File.exists?(directory)
   args = options[:yardoc] ? %w{yardoc --no-private} : %w{rdoc --inline-source --format=html -T hanna}
   args += ['-o', directory]
   args += doc_opts
   args += Dir['lib/**/*.rb']
   ["README.rdoc", "LICENSE.TXT"].each {|e| args << e if File.exists?(e) }
   system(*args)
   directory + '/index.html'
  end

  #@options :push=>true
  # Publish with grancher
  def publish(options={})
    require 'grancher'
    grancher = Grancher.new do |g|
      g.branch = 'gh-pages'
      g.push_to = 'origin'
      g.directory 'website'
    end
    grancher.commit
    if grancher.push_to && options[:push]
      grancher.push 
      puts "Published website."
    end
  end

  #@options :repo=>:string, :update_feed=>:boolean
  # Create project website
  def website(options={})
    @website = Website.new(options)
    FileUtils.mkdir_p('website')
    page = Dir.pwd + '/website/index.html'
    config = @website.fetch_config
    File.open(page,'w') {|f| f.write @website.create_web_page(config) }
    @website.post_create_hook
  end

  # Edit repos/website config file
  def config_website
    system(ENV['EDITOR'], Website.new.repo_config_file)
  end

  # Display repositories with outdated pages
  def manage_website
    Website.new.manage
  end
end

# These are my customizations of fetch_config() and create_web_page().
# They won't work for you since my github user + local files are hard coded.
module MyPages
  def post_create_hook
    save_repo_version
  end

  def manage
    super
    current_version = latest_template_version
    outdated_repos = YAML::load_file(repo_versions_file).select {|k,v|
      v != current_version
    }.map {|e| e[0]}
    puts "Following repositories are out of date: #{outdated_repos.join(', ')}"
  end

  def repo_versions_file
    File.join(File.dirname(__FILE__),'repo_versions.yml')
  end

  def latest_template_version
    `cd ~/code/repo/thor-tasks; git log -1 gh_pages.thor` =~ /^commit (\S+)\n/
    $1
  end

  def save_repo_version
    versions = YAML::load_file(repo_versions_file) rescue {}
    versions[@repo] = latest_template_version
    File.open(repo_versions_file, 'w') {|f| f.write versions.to_yaml}
  end

  def fetch_config
    config = super
    config[:description] ||= extract_description
    config[:summary] ||= fetch_summary(@repo)
    config
  end

  def fetch_summary(repo)
    begin
      json_file = File.join(File.dirname(__FILE__), "github-cldwalker.yml")
      if File.exists?(json_file) && !options[:update_feed]
        json = YAML::load_file(json_file)
      else
        puts "Fetching description ..."
        json = Boson.invoke :get, "http://github.com/api/v1/json/cldwalker", :parse=>true
        File.open(json_file, 'w') {|f| f.write json.to_yaml}
      end
      if (json_repo = json['user']['repositories'].find {|e| e['name'] == repo })
        json_repo['description']
      else
        puts "Repo '#{repo}' not found."
        ''
      end
    rescue
      "Failed while fetching description."
    end
  end

  def extract_description
    File.read(Dir.pwd + "/README.rdoc") =~ /==\s*Description(.*?)==/m if File.exists?("README.rdoc")
    if ($1)
      require 'rdoc/markup/to_html'
      rdoc_string = $1.gsub(/\n+/, ' ')
      RDoc::Markup::ToHtml.new.convert(rdoc_string)
    else
      ''
    end
  end

  def create_web_page(config)
    body = super
    layout_file = File.read('/Users/bozo/code/repo/cldwalker.github.com/_layouts/master.html')
    page_string = layout_file.gsub('{{ content }}', body).gsub('{{ page.title }}',
      config[:repo]).gsub("{% include meta_seo.html %}", seo_string(config))
    page_string.gsub('/stylesheets', 'http://tagaholic.me/stylesheets')
  end

  def seo_string(config)
    %[
      <meta name="keywords" content="#{config[:keywords]}" />
      <meta name="description" content="#{config[:description][0,160]}" />
    ]
  end
end

class Website
  attr_reader :options
  def initialize(options={})
    @options = options
    @repo = options[:repo] || File.basename(Dir.pwd)
    extend MyPages
  end

  def fetch_config
    config = YAML.load_file(repo_config_file)
    config = config[@repo] || {}
    config[:repo] = @repo
    config
  end

  def post_create_hook; end

  def repo_config_file
    File.join(File.dirname(__FILE__), 'repos.yml')
  end

  def string_from_template(file, variables)
    variables.each {|k,v| instance_variable_set("@#{k}", v) }
    translated_string = ::ERB.new(File.read(file)).result(binding)
  end

  def create_web_page(config)
    template = File.dirname(__FILE__) + '/index.rhtml'
    string_from_template(template, config)
  end
end
