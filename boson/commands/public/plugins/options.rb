module ::Boson::Options::Date
  def create_date(value)
   Date.parse(value + "/#{Date.today.year}")
  end

  def usage_for_date(opt)
    default_usage opt, "MM/DD"
  end
end

module OptionsLib
  def self.after_included
   ::Boson::OptionParser.send :include, ::Boson::Options::Date
  end
end
