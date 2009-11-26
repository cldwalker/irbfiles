module FileLib
  # @options :file=>true
  def md5_hash(str, options={})
    require 'digest/md5'
    Digest::MD5.hexdigest(options[:file] ? File.read(str) : str)
  end

  # @options :file=>true
  def sha1_hash(str, options={})
    require 'digest/sha1'
    Digest::SHA1.hexdigest(options[:file] ? File.read(str) : str)
  end

  # @options :file=>true, :algorithm=>{:type=>:string, :values=>[:sha1, :md5]}
  def files_equal?(file1, file2, options={})
    if options[:algorithm] == 'sha1'
      sha1_hash(file1, options) == sha1_hash(file2, options)
    elsif options[:algorithm] == 'md5'
      md5_hash(file1, options) == md5_hash(file2, options)
    else
      require 'ftools'
      File.compare(file1, file2)
    end
  end

  def encrypt(file, encrypted_file)
    args = %w{openssl des3 -salt -in} << file << '-out' << encrypted_file
    system *args
  end

  def decrypt(encrypted_file, normal_file)
    args = %w{openssl des3 -d -salt -in} << encrypted_file << '-out' << normal_file
    system *args
  end
end