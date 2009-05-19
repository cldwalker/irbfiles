Description
===========

Contains libraries of irb snippets and commands, some original and some copied.
These libraries are managed by my irb manager, [boson](http://github.com/cldwalker/boson).


Try/Install
===========

You'll need to download [boson](http://github.com/cldwalker/boson).
<temporary>
Until I make boson a gem, you'll need to download it locally and use
[local_gem](http://github.com/cldwalker/local_gem) to point to its location.
</temporary>

To try what I have setup, execute `irb -f -rirbrc` in this project's base directory.
Of course you can take out the -f if you want to also load up your custom irbrc but it may conflict
with what I have setup.

If you like this irb setup, modify symlink\_files.rb and irbrc.rb to point to your preferred directories.
Make sure the destinations are correct since the installer will overwrite them. Run `ruby symlink_files.rb`.
