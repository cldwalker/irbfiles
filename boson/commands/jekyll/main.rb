# Wrote a post about an old thor-version of this library:
# http://tagaholic.me/2009/02/19/meta-templates-for-github-pages.html
module Main
  def self.included(mod)
    require 'erb'
  end

  # Creates tag xml pages
  def tag_xml_pages(*tags)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    tags.each {|e|
      create_tag_page(e, 'tag/tag.xml', options)
    }
  end

  # @options :editor=>:boolean, :local=>:boolean, :verbose=>:boolean
  # Create new jekyll blog post
  def new_post(*args)
    options = args[-1].is_a?(Hash) ? args.pop : {}
    template_file = File.dirname(__FILE__) + '/_posts/new_post.textile'
    basename = Date.today.to_s + "-#{args.join('-')}"
    output_file = "_posts/#{basename}.textile"
    title = args.map {|e| e.capitalize}.join(' ')
    result = string_from_template(template_file, :title=>title)
    output_file = create_output_file(output_file, result, options)
    system(ENV['EDITOR'], output_file) if options[:editor]
  end

  # Print post counts per tag
  def tag_counts
    JekyllTags.tag_count.each do |tag,count|
      puts "#{tag}: #{count}"
    end
  end

  # @options :tags=>:boolean
  # Generate json for posts + tags
  def json(options={})
    posts_array = JekyllTags.post_tags
    if options[:tags]
      machine_tags = posts_array.map {|e| e[1]}.flatten.uniq.sort.map {|e| {:name=>e} }
      File.open(JekyllTags.root_dir + '/machine_tags.json', 'w') {|f| f.write machine_tags.to_yaml }
    else
      require 'activesupport'
      posts_array = posts_array.map {|post, tags|
        blank, date, slug = File.basename(post).split(/(\d\d\d\d-\d\d-\d\d)-(.*)\.(\w+)/)
        new_post = "/" + date.gsub("-", "/") + "/#{slug}.html"
        title = slug.split('-').map {|w| w.capitalize! || w }.join(' ')
        {:url=>new_post, :tags=>tags, :title=>title}
      }
      File.open(JekyllTags.root_dir + '/feeds/posts.json', 'w') {|f| f.write posts_array.to_json }
    end
  end

  private
  def create_tag_page(tag, template_file, options)
    output_file = template_file.sub("/tag", "/#{tag}")
    result = string_from_template(template_file, :tag=>tag)
    create_output_file(output_file, result, options)
  end

  def create_output_file(relative_file, output, options)
    #destination_dir = options[:local] ? '_site' : root_dir
    #FileUtils.mkdir_p(destination_dir)
    destination_dir = Dir.pwd
    destination_file = File.join(destination_dir, relative_file)
    FileUtils.mkdir_p File.dirname(destination_file)
    puts "Created file: #{destination_file}" if options[:verbose]
    File.open(destination_file, 'w') {|f| f.write(output) }
    destination_file
  end

  def string_from_template(file, variables)
    variables.each {|k,v| instance_variable_set("@#{k}", v) }
    translated_string = ::ERB.new(File.read(file)).result(binding)
  end
end

# helper methods used mainly for my Jekyll tags
module JekyllTags
  extend self

  def root_dir
    Dir.pwd
    #File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def all_tags
    tag_count.keys
  end

  def posts_dir
   File.join(root_dir, '_posts')
  end

  #Returns all posts under _posts
  def posts
    Dir["#{posts_dir}/**"].select {|e| e !~ /~$/ }
  end

  #array of posts with their tags
  def post_tags
    posts.map do |e|
      yaml = YAML::load_file(e)
      [e, yaml['tags']]
    end
  end

  def common_tags
    posts = post_tags
    current_tags = posts[0][1]
    posts.map {|e| [e[0], e[1] & current_tags] }
  end

  #array of tags with their counts
  def tag_count
    count = {}
    post_tags.each do |post, tags|
      tags.each do |t|
        count[t] ||= 0
        count[t] += 1
      end
    end
    count
  end
end
