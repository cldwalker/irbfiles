module Gem
  def self.included(mod)
    require 'yaml'
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
      else
        false
      end
    end
  end

  def gem_approved
    table gem_config[:approved]
  end

  def gem_add(name)
    gem_save(gem_config[:approved] << name)
  end

  def gem_remove(name)
    if gem_recursive_uninstall(name)
      approved = gem_config[:approved]
      approved.delete(name.to_s)
      gem_save(approved)
    end
  end

  def gem_check
    yaml = gem_config
    gem_list - yaml[:approved] - yaml[:system] - yaml[:approved].map {|e| gem_recursive_deps(e)}.flatten - yaml[:exception]
  end

  def gem_rdep(name)
    ::Gem.source_index.gems.values.select {|e| e.dependencies.any? {|e| e.name == name && e.type == :runtime}}.
      map {|e| "#{e.name}-#{e.version}" }
  end

  def gem_recursive_deps(name)
    gem_deps(name).map {|e| [e] + gem_recursive_deps(e) }.flatten.uniq
  end

  def gem_save(approved_gems)
    new_config = gem_config.merge(:approved=>approved_gems)
    File.open(gem_file, 'w') {|f| f.write(new_config.to_yaml) }
  end

  def gem_config
    YAML::load_file(gem_file)
  end

  def gem_file
    File.join(Boson.base_dir, 'config', 'gems.yml')
  end

  def gem_list(query='')
    ::Gem.source_index.gems.values.map {|e| e.name}.uniq.grep(/#{query}/)
  end
end