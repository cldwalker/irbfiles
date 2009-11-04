module Backup
  #s3sync.rb comes from http://s3sync.net
  # @options :directory=>:string, :s3sync_options=>:string
  # Back up files to s3
  def s3(options={})
    directories = options[:directory] ? [options[:directory]] : ['~/code','~/docs', '~/backup']
    directories.each do |e|
      cmd = "s3sync.rb --exclude=~$ -rvs #{options[:s3sync_options]} --progress #{e} cldwalker:"
      system cmd
    end
  end

  # Keep lists of system files you don't need to backup but still want to track
  def system_lists
    cmds = [ ['gem list', 'gems'], ['port installed','ports'], ['ls ~/apps', 'apps.ls'],
      ['find /mnt/m', 'm.find'], ['find ~/Music/mine', 'music.find'], ['find ~/Pictures',
      'pictures.find'], ['find ~/misc', 'misc.find']
    ]
    cmds.each do |shell_cmd, file|
      cmd = "#{shell_cmd} > #{File.join('~/backup/lists', file)}"
      system cmd
    end
  end

  # Sync local files to backup directory
  def sync_local
    sync_hash = {
     ['~/Library/Application\\ Support/Firefox', '~/Library/Application\\ Support/Quicksilver',
     '~/Library/Preferences' ] =>'library/',
     ['~/.boson', '~/.sake', '~/.cronrc', '~/.gemrc', '~/.gitconfig', '~/.gem/specs']=>'dotfiles/',
    }
    sync_hash.each do |src, dest|
      src.each do |e| 
        cmd = "rsync -av #{e} #{File.join('~/backup', dest)}"
        system cmd
      end
    end
  end

  # Local backups + s3 backup
  def local_and_s3
    local
    s3
  end

  # Db and sync + lists in one
  def local
    db_dump
    sync_local
    system_lists
    commit_git_repo("~/backup")
  end

  # @options :file=>:string, :db=>'tag_tree_dev'
  # Dumps db to a file
  def db_dump(options={})
    file = options[:file] || "#{options[:db]}-mysql.sql"
    output_file = File.join("~/backup", file)
    cmd = "mysqldump --add-drop-table --add-locks #{options[:db]} > #{output_file}"
    system(cmd)
  end

  private
  def commit_git_repo(repo_dir)
    cmd = "cd #{repo_dir}; git add -u .; git add *; git commit -m 'auto backup: #{Time.now}'"
    system(cmd)
  end
end
