Description
===========

Contains libraries of ruby commands/snippets, some original and some copied.
These libraries are managed and run by my command framework, [boson](http://github.com/cldwalker/boson).
Despite what the project name implies, all these commands can be used within ripl(irb) or from the
commandline thanks to boson.

Outline of this Repo
====================

Here's a brief outline and description of major directories under boson/:

* config/: Boson config directory
* commands/: Contains all currently used libraries.
  * core/: Libraries that either extend core Ruby classes or take an object of a core class as its first argument.
  * public/: Public libraries that I encourage everyone to use. Commands should have descriptions. If something
    is buggy here feel free to fork and pull.
    * plugins/: Plugin libraries that extend Boson's behavior.
    * site/: Libraries related to specific websites and their APIs.
    * url/: Libraries that generate url strings. When used in conjunction with
      exp/plugins/url_libraries plugin, can be used to open browser to generated urls.
      Inspired by [queriac](http://github.com/cldwalker/queriac).
    * rails/: Rails-related libraries.
  * exp/: Experimental libraries that one day should be public. These libraries are usually half-baked good ideas that
    haven't quite realized their full potential. You'll probably to need to run edge versions of
    hirb and boson for these to work.
  * personal/: Personal libraries that are specific to my computer setup i.e. my system files or operating system setup.
* lib/: A local loaded\_path containing classes used by commands.
* test/: Tests to go along with libraries.
* todo/: Interesting snippets, mostly copied, that haven't been converted to commands.

Using a Library
===============

If you want to just try one or two libraries/files under boson/ without boson, simply require and include them:

    $ ripl -f
    >> require "boson/commands/public/color"
    >> class<<self; include Color; end

Note: this only works for libraries that don't depend on other libraries, don't use boson commands
and don't rely on boson for default options.

If you want to install a boson library using boson:

    # make sure to point to the code only url
    bash> boson install http://github.com/cldwalker/irbfiles/raw/master/boson/commands/public/irb_core.rb

Install
=====

If you want to use boson in ripl(irb) as a I do:

* Clone this project: git clone git://github.com/cldwalker/irbfiles.git
* Install [boson](http://github.com/cldwalker/boson): gem install boson boson-more
* Save your ~/.irbrc to somewhere else temporarily. *Important* since the next step will symlink
  over this file.
* Run symlink_files.rb to symlink to ~/.boson and ~/.irbrc
* This irbrc uses a lot of gems. To instally them all, use [rip](http://github.com/defunkt/rip):
  `rip install http://github.com/cldwalker/dotfiles/raw/9a2b64d02fa0719502c6ee59efdf7a0cfca03899/.rip_envs/irb.rip`

To see all the command goodies available to you:

    # from ripl
    >> libraries

    # from commandline
    bash> boson libraries
