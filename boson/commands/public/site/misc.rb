module MiscLib
  def self.config
    {:dependencies=>['public/boson']}
  end

  # Downloads the raw form of a github repo file url
  def raw_file(file_url)
    download file_url.sub('blob','raw')
  end
end