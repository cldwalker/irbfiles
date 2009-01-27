Description
===========

 Currently contains snippets (mine + others) and core class extensions when irb-ing.
Since I use irb enough as a shell, some kind of custom irb manager will come from here.
This irb manager will at minimum manage commands (ruby methods) ie list, search and alias them.

Try/Install
===========

To simply try what I have setup, execute `irb -f -rirbrc` in this project's base directory.
Of course you can take out the -f if you want to also load up your custom irbrc but it may conflict
with what I have setup.

If you like this irb setup, modify symlink\_files.rb and irbrc.rb to point to your preferred directories.
Make sure the destinations are correct since the installer will overwrite them. Run `ruby symlink_files.rb`.
