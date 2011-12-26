### Blog post no. 3

Frank (as of 1.0) has support for saving "templates" in `~/.frank_templates`. This is very handy if find yourself wanting a custom starting point. All you have to do to use the feature is create a `~/.frank_templates` folder and start putting templates in it.

Once you have a few templates saved, when you run `frank new <project_path>` you'll be presented with a list of templates to choose from as the starting point for the project.

Frank was designed to make controllers unnecessary. But, sometimes it's nice to have
variables in your templates / layouts. This is particularly handy if you want to set the page
title (in the layout) according to the view. This is simple, now, with meta data.

Meta fields go at the top of any view, and are written in [YAML][13]. To mark the end
of the meta section, place the meta delimeter, `META---`, on a blank line. You can
use as many hyphens as you'd like (as long as there are 3).

Meta fields are then available as local variables to all templating languages that
support them--in the view & layout.