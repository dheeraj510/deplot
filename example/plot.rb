require '../deplot.rb'

page "/" do
	list "posts"
	layout "index.erb"
	menu "1-Blog"
end

pages "/post/{name}" do
	layout "layout.erb"
	list "posts"
	menu "1-2-Post"
end

page "/about" do
	process "about.md"
	menu "2-About"
end

publish