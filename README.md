deplot
======

Deplot is a static web site generator with a ruby DSL.

Intention
---------

Deplot is intended to simplify the progress of creating and maintaining a static web site. Its main advantages are:

* Separating content from markup with layout (template) files
* Independency from specific markup languages by using [tilt][tilt] in both layout and content files
* Simplifying the design/development workflow with pre-built Guardfile that allows [guard][guard] to recompile any asset or the whole project if a source file changes.
* Easy deployment with a folder structure ready for [git-ftp][git-ftp]

Installation and usage
-----

Install the deplot gem via rubygems.org: `gem install deplot`. Or build it directly from the sources with `gem build deplot.gemspec; gem install deplot-0.0.x.gem` in the cloned repo. For both `gem install` commands, admin rights may be required.

If the deplot gem is installed, calling `deplot new <project_name>` will create a project directory with all the files and directories needed to get a new site started. You can also use an existing skeleton with `deplot new <project_name> <git_url>`, which will clone the specified git repo. Deplot's built upon a custom DSL that's used to describe your site's pages (in the `Deplotfile`):

```ruby
path "/" do
	render "index.markdown"
end
```

You can create multiple pages from multiple source files with `render_all` (the `#` is replaced by the file name with `.html` extension):

```ruby
path "/blog/#" do # will create /blog/<file_name>.html
	render_all "blog/"
end
```

or create an index file from multiple sources:

```ruby
path "/blog/" do # will create /blog/index.html
	render_all "blog/"
end
```

Deplot uses [tilt][tilt] to render the source and layout file/s, so it can be used with almost every markup language and template engine.

Assets like `LESS`, `SASS` or `CoffeeScript` files are compiled by [guard][guard], which will also call deplot if any content or layout changes. Take a look at the default `Guardfile`, which has usable default settings. Or just run `guard` and press `enter` to compile everything.

Since all files are compiled into the root directory of the project, you can deploy your site with [git-ftp][git-ftp] - the project's page has details on how to deploy a git repo with git-ftp.

Development
-----------

To use the latest version, you will need to manually build and install the gem. A `gem build deplot.gemspec; sudo gem install deplot-0.0.x.x.gem` in the cloned repo will suffice.

License
-------

See LICENSE file.

[tilt]: https://github.com/rtomayko/tilt
[guard]: https://github.com/guard/guard
[git-ftp]: https://github.com/resmo/git-ftp