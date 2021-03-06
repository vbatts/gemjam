# Gemjam

Create java jar, for jRuby, from gems or a bundler Gemfile

## Installation

Add this line to your application's Gemfile:

    gem 'gemjam'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gemjam


## Dependencies

On fedora, for the java `jar` command:

	yum install java-devel-openjdk


## Usage

Package up a specific version of one gem, and latest version of another

	gemjam -g sinatra,1.3.5 -g hurp

Package up the dependencies from the Gemfile in the current directory

	gemjam -b

Combo, but Gemfile from another directory

	gemjam -b ../foo/Gemfile -g sinatra,1.3.5 -g hurp

You'll get an output like

	$ gemjam -g sinatra
	{:jruby=>"jruby", :gems=>["sinatra"]}
	Successfully installed rack-1.5.2
	Successfully installed tilt-1.4.1
	Successfully installed rack-protection-1.5.0
	Successfully installed sinatra-1.4.3
	4 gems installed
	Created d20130723-10726-1sgce23.jar

To grep only the jar name

	$ gemjam -g sinatra | grep -e ^Created.*jar$ | cut -d " " -f 2
	d20130723-10726-1sgce23.jar

To specify an alternate jruby executable

	$ gemjam -j "java -jar ~/Downloads/jruby-complete-1.7.4.jar" -g sinatra
	{:jruby=>"java -jar ~/Downloads/jruby-complete-1.7.4.jar", :gems=>["sinatra"]}
	Successfully installed rack-1.5.2
	Successfully installed tilt-1.4.1
	Successfully installed rack-protection-1.5.0
	Successfully installed sinatra-1.4.3
	4 gems installed
	Created d20130723-24156-1omlum7.jar

How this is used practically aftwards

	$ gemjam -j "java -jar ~/Downloads/jruby-complete-1.7.4.jar" -g rye
	{:jruby=>"java -jar ~/Downloads/jruby-complete-1.7.4.jar", :gems=>["rye"]}
	Successfully installed highline-1.6.19
	Successfully installed annoy-0.5.6
	Successfully installed storable-0.8.9
	Successfully installed drydock-0.6.9
	Successfully installed sysinfo-0.8.0
	Successfully installed net-ssh-2.6.8
	Successfully installed net-scp-1.1.2
	Successfully installed docile-1.0.3
	Successfully installed rye-0.9.8
	9 gems installed
	Created d20130723-835-1i0moio.jar
	$ java -jar ~/Downloads/jruby-complete-1.7.4.jar -r ./d20130723-835-1i0moio.jar -r rye -e 'puts Rye::Box.new("mybox.example.com").uptime'
	 23:36:22 up 133 days,  9:23,  0 users,  load average: 0.06, 0.05, 0.05


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
