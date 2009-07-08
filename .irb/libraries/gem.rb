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
    if shell('gem','dependency',name) =~ /(Gem #{name}-.*?)(Gem|\z)/m
      $1.split("\n").grep(/runtime\s*\)/).map do |line|
        line[/[\w-]+/]
      end.compact
    else
      []
    end
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

  def gem_list(query='')
    # Gem.source_index.gems.keys
    shell('gem', 'list', query).split("\n").map {|e| e[/[\w-]+/] }
  end
end