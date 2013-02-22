Gem::Specification.new do |s|
  s.name        = 'deplot'
  s.version     = '0.1.0'
  s.date        = '2012-04-29'
  s.description = "A ruby static web site generator"
  s.summary     = s.description
  s.authors     = ["Cyril Nusko"]
  s.email       = 'gitcdn@gmail.com'
  s.files       = ["bin/deplot"]
  s.homepage    = 'http://www.github.com/cdn64/deplot'
  s.executables << 'deplot'
	s.files = %w[
		Gemfile
		LICENSE
		README.md
		bin/deplot
		deplot.gemspec
	]
	s.add_dependency 'thor', "~> 0.14.6"
	s.add_dependency 'tilt', "~> 1.3.3"
	s.add_dependency 'colorize'
end