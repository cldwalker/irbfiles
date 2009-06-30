module Gem
  def self.included(mod)
    require 'libraries/shell'
  end

  def gem_menu(command)
    menu(gem_list) do |e|
      system('sudo', 'gem',command, *e)
    end
  end

  def gem_list(query='')
    shell('gem', 'list', query).split("\n").map {|e| e[/[\w-]+/] }
  end
end