module ::Boson::Options::Date
  def create_date(value)
   # value_shift should be mm/dd
   Date.parse(value + "/#{Date.today.year}")
  end
end

module OptionsLib
  def self.after_included
   ::Boson::OptionParser.send :include, ::Boson::Options::Date
  end
end
