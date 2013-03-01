# deplot

Deplot is a lightweight and very extensible static web site generator written in ruby.

## Intention

Deplot is intended to simplify the process of creating and maintaining a static web site. Its simple DSL makes it easy to describe and understand the structure of a web site, while giving you power over every part of the building process.

## Using deplot

### Installing

The current deplot gem is published on rubygems.org, so you only need to type the following command into your favorite shell (`sudo` may be necessary, depending on your setup):

```
$ gem install deplot
```

### The structure of a deplot project

A standard deplot project consists of a folder (the *root folder*) with the following structure:

```
- assets/
- Deplotfile
- documents/
- media/
- modules/
```

Only the Deplotfile is necessary for deplot to run without errors; but in order to build a website, you probably need some content. By default, all output goes to this *root* directory: as soon as you build the project, the root folder will contain a lot more folders and files.

### A simple example

The core of a deplot project, the `Deplotfile`, uses the mentioned DSL that makes it easy to understand the different processes to build the website.

For example, if you were to set up a blog with one page per blog post and a collection of posts on the front page, you could write this simple code:

```
documents_in "posts" do
	collect_in "index.html"
	output_to "posts"
end
```

Now every post in `documents/posts/` is first being collected in `index.html` and then rendered into its single page, `posts/<filename>.html`.

To make this work, you first need to install the deplot gem and invoke deplot like this:

```
$ deplot make
```

Deplot uses [tilt][tilt] to render all content and layout files and is therefore able to process almost anything from ERB to Markdown.

### Command reference

#### Render blocks

The top-level **render blocks**  are built using the two methods `documents_in` (as seen in the previous example) and `media_in`. They are called with two arguments: the path to the folder containing the source files (relative to `documents/` and `media/`, respectively) and a block that contains all the instructions for rendering the sources. At the moment, `media_in` is currently only able to filter and copy files:

```
media_in "images" do
	filter :only => [/.*.png$/]
	copy_to "img"
end
```

#### Inline render blocks

There are situations in which you may want to render multiple sets of files to different parts of your website (a newsticker in the sidebar, for example). The two commands `output_documents_in` and `collect_documents_in` will take care of this by returning the rendered content as array and string, respectively. In the following example, both layout and content files could then make use of the variable "@news":

```
documents_in "pages" do
	@news = collect_documents_in "news"
	output_to "/"
end
```

#### copy_to (media only)

`copy_to` does exactly what you would expect of it: it copies the source files into the specified directory.

#### output_to (documents only)

`output_to` is the equivalent to `copy_to` in that it renders every source into a single file in the given directory. Unlike `copy_to`, it is able to take a block as last argument that can be used for instructions *specific to this output directory*.

#### collect_in (documents only)

`collect_in` concatenates all the rendered files and writes them to a single file. Like `output_to`, it can be called with a block (the `apply` example makes use of this feature).

#### filter

The `filter` command is available for both media and document renderers and is used to filter out files from the specified sources. It can be used in two ways:

```
filter :only => [/.*.markdown$/]
filter :exclude => [/.*.erb$/]
```

#### apply

The mightiest of all commands, `apply`, can be used to execute custom code (so-called *modules*) in the context of the current set of sources. Modules are searched for in the `modules/` folder of your project and need to be included in the Deplotfle (`use :teaser` for `teaser.rb`). For our basic blog, we may want to shorten the text displayed on the front page and display a link to the post page:

```
class Teaser < DeplotPreprocessor
  def preprocess source, arguments
    link = "posts/" + File.basename(source[:filename]).gsub(/\.md/, ".html")
    source[:content] = "#{source[:content][0..40]}… <a href=\"#{link}\">Read on &raquo;</a>"
  end
end
```

Now we can include this preprocessor to be used for `index.html` as follows:

```
use :teaser

documents_in "posts" do
	collect_in "index.html" do
		apply :teaser
	end
	output_to "posts"
end
```

There are three types of modules: the filter, the preprocessor, the processor modules.

* **Filter modules** are used to sort out files and can be applied everywhere.
* **Preprocessor modules** (documents only) alter the *source code* of the documents (text written in markdown, for example). They cause deplot to read the source files and can't be executed after processor modules.
* **Processor modules** (documents only) are used to alter *rendered code* (HTML, for now). They cause deplot to read *and* render the source files and need to be executed after preprocessor modules.

#### layout (documents only)

`layout` is used to specify a template file which is rendered just before the files is written to disk. This file can be used to link to css and javascript files or display content that stays the same over multiple pages:

```
<html>
<head>
	<link rel="stylesheet" href="style.css" />
</head>
<body>
	<h1>Page title</h1>
	<div class="wrapper">
		<%= yield %>
	</div>
</body>
</html>
```


## Planned features

* Ability to use custom renderer code (block and module)
* Non-media asset processing (compiling, compressing, concatenating) for files written in LESS, SASS, CoffeScript etc. 
* Filter: keep or discard file when one or more, but not necessarily all conditions are met (considered bug)
* Automatic rebuilding using [guard][guard]
* Media resizing and conversion
* Partials (for more modular layouts)
* Ability to sort source files

Please submit feature requests and bugfixes in the issue tracker.

## License

See LICENSE file.

[tilt]: https://github.com/rtomayko/ti
[guard]: https://github.com/guard/guardlt