=begin
This could just as well be a shell script ...

Create a *.jar, for jRuby, from installing gems or a bundler Gemfile

--vbatts
=end

require "gemjam/version"
require "optparse"
require "rbconfig"
require "tmpdir"
require "fileutils"

module Gemjam
  def parse_args(args)
    options = {
      :quiet => false,
      :jruby => "jruby",
      :gems  => [],
    }
    opts = OptionParser.new do |opts|
      opts.banner = File.basename(__FILE__) + "[-b [Gemfile]] [-g gem[,version]]..."
      opts.on("-q", "--quiet", "less output") do |o|
        options[:quiet] = o
      end
      opts.on("-j", "--jruby CMD", "CMD to use to call jruby (Default '#{options[:jruby]}')") do |o|
        options[:jruby] = o
      end
      opts.on("-g", "--gem GEMNAME", "GEMNAME to install. If ',<version>' is a append, it will specify that version of the gem") do |o|
        options[:gems] << o
      end
      opts.on("-b", "--bundle [GEMFILE]", "make the gemjar from a current directory Gemfile or specified") do |o|
        if o.nil? and ! FileTest.file?("Gemfile")
          raise "No Gemfile present or provided"
        end
        options[:bundle] = if o.nil?
                             File.join(Dir.pwd, "Gemfile")
                           else
                             File.expand_path(o)
                           end
      end
    end.parse!(args)
    return options
  end

  # runs +cmd+, and sets $? with that commands return value
  def cmd(cmd_str, quiet = false)
    p cmd_str unless quiet
    IO.popen(cmd_str) do |f|
      loop do
        buf = f.read(1)
        break if buf.nil?
        unless quiet
          print buf
          $stdout.flush
        end
      end
    end
  end

  # install rubygem +gemname+ to directory +basedir+ using jruby command +jruby+
  # 
  # sets $? with that commands return value
  def gem_install(jruby, basedir, gemname, quiet = false)
    if gemname.include?(",")
      g, v = gemname.split(",",2)
      cmd("#{jruby} -S gem install -i #{basedir} #{g} -v=#{v}", quiet)
    else
      cmd("#{jruby} -S gem install -i #{basedir} #{gemname}", quiet)
    end
  end

  # pack up the installed gems in +dirname+, to jar file +jarname+
  # 
  # sets $? with that commands return value
  def make_jar(jarname, dirname, quiet = false)
    cmd("jar cf #{jarname} -C #{dirname} .", quiet)
  end

  # install the bundle, using jruby command +jruby+
  # 
  # sets $? with that commands return value
  def bundle_install(jruby, quiet = false)
    cmd("#{jruby} -S bundle install --path ./vendor/bundle/", quiet)
  end

  def bundler_vendor_dir
    return ["vendor","bundle",
            RbConfig::CONFIG["ruby_install_name"],
            RbConfig::CONFIG["ruby_version"]].join("/")

  end

  def main(args)
    o = parse_args(args)
    p o unless o[:quiet]

    tmpdir = Dir.mktmpdir
    begin
      cwd = Dir.pwd
      if o[:bundle]
        FileUtils.cd tmpdir
        FileUtils.cp o[:bundle], "Gemfile"
        bundle_install(o[:jruby], o[:quiet])
        FileUtils.cd cwd
        abort("FAIL: bundler returned: #{$?}") if $? != 0
      end

      o[:gems].each do |gem|
        gem_install(o[:jruby], File.join(tmpdir, bundler_vendor_dir), gem, o[:quiet])
        abort("FAIL: gem install returned: #{$?}") if $? != 0
      end

      jarname = File.basename(tmpdir) + ".jar"
      make_jar(jarname, File.join(tmpdir, bundler_vendor_dir), o[:quiet])
      abort("FAIL: jar packaging returned: #{$?}") if $? != 0

      if o[:quiet]
        puts jarname
      else
        puts "Created #{jarname}"
      end
    ensure
      # remove the directory.
      FileUtils.remove_entry_secure(tmpdir, true)
    end
  end
end
