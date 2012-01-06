deplot
======

Deplot is a ruby DSL to easily create and manage a static web site.

Syntax
------

There is one file in a `deplot` project that specifies how to put the final product together, the 'plot' file. The imported `deplot.rb` file defines a small set of simple methods to do this, as shown in the example:

```ruby
require 'deplot.rb'

page "/" do
	process "index.md"
	layout "index.erb"
	menu "1-Home"
end
```

This code describes a single page, at the location `/`, that consists of a layout (template) `index.erb` showing the rendered markdown document `index.md`. `Deplot` uses [tilt][tilt] to render all content, so you can write in almost every markup language. Moreover, the location of the page is specified (with `menu "1-Home"`), and can be used to display a simple navigation.

It is possible to use more than one source to render a page, or to create multiple pages from multiple sources (the `example/` folder contains a simple blog built with `deplot` that uses this feature for its front page and `posts/` folder).

The `deplot.rb` source has a few comments on the main methods, if you want to find out more about the way `deplot` works. Read it conveniently in your browser with [rocco][rocco].

Install
-------

To use `deplot`, your plot file needs to include the `deplot.rb` file:

	require 'deplot.rb'
	
In addition, the directory in which your plot is executed must have the folders `content/` and `templates/`. The example is a good starting point for any project; there are still a lot of bugs that will possibly cause `deplot` to crash when in another setup.

Issues and possible future features
-----------------------------------

* custom directories for `content/`, `resources/`, `template/` and `output/` (which would, for example, enable easy `git-ftp` deployment)
* `sass` and `less` compilation for files in the 'resources/' folder
* exhaustive README

License
-------

See LICENSE file.

[tilt]: https://github.com/rtomayko/tilt
[rocco]: https://github.com/rtomayko/rocco