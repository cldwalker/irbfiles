module SymbolLib
  # Enable items.map(&:name) a la Rails
  def to_proc(sym)
    lambda {|*args| args.shift.__send__(sym, *args)}
  end
end 