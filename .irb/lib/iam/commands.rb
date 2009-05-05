module Iam
  module Commands
    def commands
      puts Hirb::Helpers::Table.render(Iam.commands, :fields=>[:name, :lib, :alias])
    end

    def libraries
      puts Hirb::Helpers::Table.render(Iam.libraries, :fields=>[:name, :type])
    end  
  end
end