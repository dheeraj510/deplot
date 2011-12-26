# Copyright (c) 2011 Cyril Nusko
# See "LICENSE"

require 'rubygems'
require 'tilt'

require 'fileutils'

class Deplot
	class << self
		attr_accessor :list_folder, :process_file, :layout
	end

	@list_folder	= nil
	@process_file	= nil
	@layout			= "layout.erb"
	@current_menu	= nil
	@current_menu_number = 0

	@menus = {}

	@tasks = []

	@write_tasks = []

	def self.reset
		@menus.nil? ? {} : @menus
		@tasks.nil? ? [] : @tasks
		@list_folder	= nil
		@process_file	= nil
		@layout			= "layout.erb"
		@current_menu	= nil
		@current_menu_number = 0
	end

	### Actions

	def self.process f
		@process_file = f
	end
	def self.list f
		@list_folder = f
	end
	def self.tasks_push task
		@tasks.push task
	end
	def self.menu text
		@current_menu = text
	end

	
	### Menu

	# Add 'location' to current menu. The location is a sting like "1-Index" or
	# "3-1-Post1". The number indicate the position in the hierarchical order
	# of the menu, the text afterwards is used as title for the link. 
	def self.add_to_menu location
		unless @current_menu.nil?
			elements = @current_menu.split(/-/)
			name = elements.pop
			# The menu currently supports only two levels.
			if elements.length == 2
				@menus[elements[0]] = (@menus[elements[0]].is_a? Array) ? @menus[elements[0]] : [nil, nil, {}]
				@menus[elements[0]][2][elements[1] + "-" + name + @current_menu_number.to_s] = [location]
			elsif elements.length == 1
				@menus[elements[0]] = [name, location, {}]
			end
		end
	end

	
	### Write-to-file task
	
	# Add a write task (name of the file and its contents) to the list. The
	# content is a block that gets executed (do\_write\_tasks) after the menu
	# is built.
	def self.add_write_task filename, &content
		@write_tasks.push [filename, content]
	end
	
	# Do all the write task: iterate through tasks, write the string returned
	# from the block to the specified file.
	def self.do_write_tasks
		Dir.chdir("output") do 
			@write_tasks.each do |filename, content|
				puts "writing '" + filename + "'..."
				file = File.open(filename, "w")
				file.write(content.call)
				file.close
			end
		end
	end

	### Helpers

	# Ensure the file is writable by creating any possible parent directories.
	def self.ensure_path file
		directory = File.dirname(file)
		begin
			Dir.mkdir(directory)
		rescue
		end
	end
	# Display info for each task (page/s).
	def self.info
		puts @process_file.nil? ? "  sources: '" + @list_folder.to_s + "'" : "  source: '" + @process_file.to_s + "'"
		puts @template.nil? ? "  default template" : "  template: " + @template.to_s
	end
	# Calculate number of directories to file; used for resource linking (css)
	# and as prefix to the menu links.
	def self.calcdepth location
		return /[^\\]\//.match(location).to_a.length
	end
	# Avoid conflicts with . and .. by skipping them.
	def self.error_if_normal_file file
		unless /^\./ =~ file
			puts "==> Error. Unable to load the file '" + file.to_s + "'."
		end
	end

	### Rendering

	# Called before rendering; removes files in 'output/' and copies all the
	# files from the 'resources' folder.
	def self.prerender
		# Remove 'output/*'.
		FileUtils.rm_rf 'output'
		Dir.mkdir 'output'
		# Copy resources.
		FileUtils.cp_r Dir.glob('resources/*'), 'output/'
	end

	# Render one page (from one or more sources)
	def self.render_one location
		puts "rendering path '" + location + "'"
		if @list_folder.nil?
			info
			# render one file into one file
			file_content = nil
			Dir.chdir "content" do
				begin
					file_content = Tilt.new(@process_file)
				rescue
					error_if_normal_file file
					return
				end
			end
			Dir.chdir "output" do
				location.sub!(/^\//, "")
				location = location == "" ? "index" : location
				ensure_path location
				location = /\/$/ =~ location ? location + "index" : location
				if /\{name\}/ =~ location
					location.sub!(/\{name\}/, file)
				end
				location += ".html"
				add_to_menu location
				if file_content.nil?
					puts "==> Fatal error. File doesn't seem to be loaded."
					return
				end
				if @layout.nil?
					add_write_task location do
						file_content.render(Object.new, {})
					end
				else
					layout = @layout
					add_write_task location do
						Tilt.new("../templates/"+layout).render(Object.new, {:path => location, :menus => @menus, :depth => calcdepth(location)}){
							file_content.render(Object.new, {:depth => calcdepth(location)})
						}
					end
				end
			end
		else
			info
			# render many files into one page
			unless File.directory? "content/"+@list_folder
				puts "==> Error. No such directory: '" + @list_folder + "'."
				return
			end
			root_path = Dir.pwd
			sources = []
			location.sub!(/^\//, "")
			location = location == "" ? "index" : location
			location = /\/$/ =~ location ? location + "index" : location
			if /\{name\}/ =~ location
				location.sub!(/\{name\}/, file)
			end
			Dir.chdir("content/"+@list_folder) do
				Dir.foreach(".") do |file|
					begin
						file_content = Tilt.new(file)
					rescue
						error_if_normal_file file
						next
					end
					sources.push file_content.render(Object.new, {})
				end
			end
			Dir.chdir "output" do
				ensure_path location
				location += ".html"
				add_to_menu location
				if @layout.nil?
					add_write_task location do
						# A layout should really be specified for this case.
						sources.join("<br />")
					end
				else
					layout = @layout
					add_write_task location do
						Tilt.new("../templates/"+layout).render(Object.new, {:path => location, :sources => sources, :menus => @menus,
							:depth => calcdepth(location)})
					end
				end
			end
		end
		puts
	end
	# Render multiple pages
	def self.render_many location
		puts "rendering path '" + location + "'"
		info
		unless File.directory? "content/"+@list_folder
			puts "==> Error. No such directory: '" + @list_folder + "'."
			return
		end
		root_path = Dir.pwd
		Dir.chdir("content/"+@list_folder) do
			number = 0
			Dir.foreach(".") do |file|
				begin
					file_content = Tilt.new(file)
				rescue
					error_if_normal_file file
					next
				end
				number += 1
				# file loaded, continue
				Dir.chdir root_path + "/output" do
					location.sub!(/^\//, "")
					location = location == "" ? "index" : location
					ensure_path location
					filename = location.sub(/\{name\}/, file).sub(/#{File.extname(file)}$/, ".html")
					add_to_menu filename
					if @layout.nil?
						add_write_task filename do
							file_content.render(Object.new, {})
						end
					else
						layout = @layout
						add_write_task filename do
							Tilt.new("../templates/"+layout).render(Object.new, {:path => location, :menus => @menus, :depth => calcdepth(location)}){
								file_content.render(Object.new, {})
							}
						end
					end
					@current_menu_number = number.to_s
				end
			end
		end
		puts
	end
	# Publish the site; this function is called at the end of the plot file
	# and renders all the content. It iterates through the tasks, calls the
	# specified blocks (of 'page' and 'pages') to get all the params and then
	# calls the right rendering function. 
	def self.publish
		puts
		Deplot.prerender
		@tasks.each do |task|
			method, location, block = task
			if method == "page"
				Deplot.reset
				block.call
				Deplot.render_one location
			else
				Deplot.reset
				block.call
				Deplot.render_many location
			end
		end
		do_write_tasks
		puts
	end
end

#### Deplot verbs

# These verbs are public and link between the plot file and the singleton
# Deplot class. Each of these verbs sets params that influence the rendering.

def layout l
	Deplot.layout = l
end

def process f
	Deplot.process f
end
def list f
	Deplot.list f
end
def add link, title
	Deplot.add link, title
end
def menu text
	Deplot.menu text
end

#### Main actions

# The 'page' and 'pages' functions are passed a location string (the
# destination) and a block that contains all param-setting function
# calls. Both of these arguments are pushed on a stack of tasks. The
# publish function will then do all these tasks.

def page location, &block
	Deplot.tasks_push ["page", location, block]
end
def pages location, &block
	Deplot.tasks_push ["pages", location, block]
end

def publish
	Deplot.publish
end