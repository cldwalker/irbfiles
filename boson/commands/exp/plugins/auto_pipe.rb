class ::Boson::OptionCommand
  alias_method :_modify_args, :modify_args
  def modify_args(args)
    _modify_args(args)
    args.unshift $stdin.read if !$stdin.tty?
  end
end