class ::Boson::BinRunner
  class <<self
    alias_method :_translate_args, :translate_args
    def translate_args(args, piped)
      args = _translate_args(args, piped)
      if commands.size > 1
        if commands.first == @command
          Scientist.render = false
        # elsif commands.last == @command
          # Scientist.render = true
        end
      end
      args
    end
  end
end