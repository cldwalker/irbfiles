module Gem
  def self.included(mod)
    require 'libraries/shell'
  end

  def gem_menu(command)
    menu(gem_list) do |e|
      system('sudo', 'gem',command, *e)
    end
  end

  def gem_deps(name)
    if (latest = latest_gem(name))
      latest.dependencies.select {|e| e.type == :runtime }.map {|e| e.name}
    else
      []
    end
  end

  def latest_gem(name)
    ::Gem.source_index.gems.values.select {|e| e.name == name }.sort_by {|e| e.version }[-1]
  end

  def gem_recursive_uninstall(name)
    deps = gem_deps(name)
    if deps.empty?
      system('sudo','gem','uninstall',name)
    else
      puts("Uninstall #{name} with dependencies: #{deps.join(', ')}? [y/n]")
      if gets.chomp[/y/]
        system(*(%w{sudo gem uninstall} + [name] + deps))
      end
    end
  end

  def gem_check
    gem_file = File.join(Boson.base_dir, 'config', 'gems.yml')
    yaml = YAML::load_file(gem_file)
    gem_list - yaml[:approved] - yaml[:system] - yaml[:approved].map {|e| gem_recursive_deps(e)}.flatten - yaml[:exception]
  end

  def gem_rdep(name)
    ::Gem.source_index.gems.values.select {|e| e.dependencies.any? {|e| e.name == name && e.type == :runtime}}.
      map {|e| "#{e.name}-#{e.version}" }
  end

  def gem_recursive_deps(name)
    gem_deps(name).map {|e| [e] + gem_recursive_deps(e) }.flatten.uniq
  end

  def gem_save(gems=gem_list)
    gem_file = File.join(Boson.base_dir, 'config', 'gems.yml')
    File.open(gem_file, 'w') {|f| f.write({:approved=>gems}.to_yaml) }
  end

  def gem_list(query='')
    # Gem.source_index.gems.keys
    shell('gem', 'list', query).split("\n").map {|e| e[/[\w-]+/] }
  end
end