# Gemjar

Create java jar, for jRuby, from gems or a bundler Gemfile

## Installation

Add this line to your application's Gemfile:

    gem 'gemjar'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gemjar

## Usage

Package up a specific version of one gem, and latest version of another

	gemjar -g sinatra,1.3.5 -g hurp

Package up the dependencies from the Gemfile in the current directory

	gemjar -b

Combo, but Gemfile from another directory

	gemjar -b ../foo/Gemfile -g sinatra,1.3.5 -g hurp

You'll get an output like

	$ gemjar -g sinatra
	{:jruby=>"jruby", :gems=>["sinatra"]}
	Successfully installed rack-1.5.2
	Successfully installed tilt-1.4.1
	Successfully installed rack-protection-1.5.0
	Successfully installed sinatra-1.4.3
	4 gems installed
	Created d20130723-10726-1sgce23.jar

To grep only the jar name

	$ gemjar -g sinatra | grep -e ^Created.*jar$ | cut -d " " -f 2
	d20130723-10726-1sgce23.jar

To specify an alternate jruby executable

	$ gemjar -j "java -jar ~/Downloads/jruby-complete-1.7.4.jar" -g sinatra
	{:jruby=>"java -jar ~/Downloads/jruby-complete-1.7.4.jar", :gems=>["sinatra"]}
	Successfully installed rack-1.5.2
	Successfully installed tilt-1.4.1
	Successfully installed rack-protection-1.5.0
	Successfully installed sinatra-1.4.3
	4 gems installed
	Created d20130723-24156-1omlum7.jar

How this is used practically aftwards

	$ gemjar -g warbler
	{:jruby=>"jruby", :gems=>["warbler"]}
	Successfully installed rake-10.1.0
	Successfully installed jruby-jars-1.7.4
	Successfully installed warbler-1.3.8
	3 gems installed
	Created d20130723-24956-4o39ld.jar
	$ jruby -r ./d20130723-24956-4o39ld.jar -S warble
	rm -f hurp.war
	Creating hurp.war


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
