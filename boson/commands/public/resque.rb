module ResqueLib
  def self.config
    {:namespace=>'rq'}
  end

  def self.after_included
    require 'resque'
  end

  # List keys
  def keys
    Resque.keys
  end

  # @render_options {}
  # List redis info
  def info
    Resque.info
  end

  # @render_options :fields=>['args', 'class'], :filters=>{'args'=>:inspect}
  # @options :offset=>0, :limit=>10
  # Lists jobs in a queue
  def jobs(queue, options={})
    Resque.peek queue, options[:offset], options[:limit]
  end

  # List queues
  def queues
    Resque.queues
  end

  # List workers
  def workers
    Resque.workers
  end

  # @render_options :fields=>%w{queue failed_at exception error payload}
  # @options :offset=>0, :limit=>10
  # List failed jobs
  def failed(options={})
    Resque.list_range 'failed', options[:offset], options[:limit]
  end
end
