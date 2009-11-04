Description
===========

Contains libraries of ruby commands/snippets, some original and some copied.
These libraries are managed and run by my command framework, [boson](http://github.com/cldwalker/boson).
Despite what the project name implies, all these commands can be used within irb or from the
commandline thanks to boson.

Command Libraries
====================

Here's a brief outline of how command libraries under commands/ are organized:

* public/: Public libraries that I encourage everyone to use. If something is buggy here feel free to fork and pull.
** plugins/: Plugin libraries that extend Boson's behavior.
** site/: Libraries related to specific websites and their APIs.
** rails/: Rails-related libraries.
* exp/: Experimental libraries that one day should be public. These libraries are usually half-baked good ideas that
  haven't quite realized their full potential.
* personal/: Personal libraries that are specific to my computer setup i.e. my system files or operating system setup.

Using a Library
===============

If you want to just try one or two libraries/files under boson/ without boson, simply require and include them:

    bash> irb -f
    irb>> require "boson/libraries/ansi"
    irb>> class<<self; include Ansi; end

Note: this only works for libraries that don't depend on other libraries, don't use boson commands
and don't rely on boson for default options.

If you want to install a boson library using boson:

    # make sure to point to the code only url
    bash> boson install http://github.com/cldwalker/irbfiles/raw/master/boson/commands/irb_core.rb

Install
=====

If you want to use irb as a I do:

* Clone this project: git clone git://github.com/cldwalker/irbfiles.git
* Install [boson](http://github.com/cldwalker/boson): gem install boson
* Save your ~/.irbrc to somewhere else temporarily. *Important* since the next step will symlink
  over this file.
* Run symlink_files.rb to symlink to ~/.boson and ~/.irbrc

To see all the command goodies available to you:

    # from irb
    >> libraries

    # from commandline
    bash> boson libraries

