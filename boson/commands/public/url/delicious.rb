module DeliciousUrl
  # @config :alias=>'dt'
  # Tag page
  def delicious_tag(tag)
    "http://delicious.com/tag/#{tag}"
  end

  # @options :user=>'cldwalker'
  # @config :alias=>'dsub'
  # Subscriptions page
  def delicious_subscriptions(options={})
    "http://delicious.com/subscriptions/#{options[:user]}"
  end

  # @config :alias=>'du'
  # @options :user=>'cldwalker'
  # User page
  def delicious_user(options={})
    "http://delicious.com/#{options[:user]}"
  end
end