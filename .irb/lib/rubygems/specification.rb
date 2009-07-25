# Overriding til github fixes their Marshal index
class Gem::Specification
  def self._load(str)
    array = Marshal.load str

    spec = Gem::Specification.new
    spec.instance_variable_set :@specification_version, array[1]

    current_version = CURRENT_SPECIFICATION_VERSION

    begin
    field_count = if spec.specification_version > current_version then
                    spec.instance_variable_set :@specification_version,
                                               current_version
                    MARSHAL_FIELDS[current_version]
                  else
                    MARSHAL_FIELDS[spec.specification_version]
                  end
    # because of github's current marshal index
    rescue
      field_count = array.size
    end

    if array.size < field_count then
      raise TypeError, "invalid Gem::Specification format #{array.inspect}"
    end

    spec.instance_variable_set :@rubygems_version,          array[0]
    # spec version
    spec.instance_variable_set :@name,                      array[2]
    spec.instance_variable_set :@version,                   array[3]
    spec.instance_variable_set :@date,                      array[4]
    spec.instance_variable_set :@summary,                   array[5]
    spec.instance_variable_set :@required_ruby_version,     array[6]
    spec.instance_variable_set :@required_rubygems_version, array[7]
    spec.instance_variable_set :@original_platform,         array[8]
    spec.instance_variable_set :@dependencies,              array[9]
    spec.instance_variable_set :@rubyforge_project,         array[10]
    spec.instance_variable_set :@email,                     array[11]
    spec.instance_variable_set :@authors,                   array[12]
    spec.instance_variable_set :@description,               array[13]
    spec.instance_variable_set :@homepage,                  array[14]
    spec.instance_variable_set :@has_rdoc,                  array[15]
    spec.instance_variable_set :@new_platform,              array[16]
    spec.instance_variable_set :@platform,                  array[16].to_s
    spec.instance_variable_set :@license,                   array[17]
    spec.instance_variable_set :@loaded,                    false

    spec
  end
end

