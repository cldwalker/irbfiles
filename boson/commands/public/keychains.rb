module Keychains
  def self.included(mod)
    require 'keychain' #rip install git://github.com/josh/keychain_services.git 
  end

  # @render_options :fields=>[:account, :label, :creation_date, :kind, :service, :comment],
  #   :sort=>:creation_date, :reverse_sort=>true
  # List osx keychains
  def keychains
    Keychain.items
  end
end
