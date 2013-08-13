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
      opts.on("-o", "--output FILENAME", "output to jar FILENAME") do |o|
        options[:output] = o
      end
      opts.on("--keep", "preserve the temp working directory (for debugging)") do |o|
        options[:keep] = o
      end
      opts.on("-c", "--cache", "preserve the cach/*.gem files in the jar") do |o|
        options[:cache] = o
      end
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
      opts.on("--with WITH", "bundle install --with 'foo bar' (if needed)") do |o|
        options[:bundle_with] = o
      end
      opts.on("--without WITHOUT", "bundle install --without 'foo bar' (if needed)") do |o|
        options[:bundle_without] = o
      end
    end.parse!(args)
    return options
  end
  module_function :parse_args

  # runs +cmd+, and sets $? with that commands return value
  def cmd(cmd_str, quiet = false, io = $stdout)
    p cmd_str unless quiet
    IO.popen(cmd_str) do |f|
      loop do
        buf = f.read(1)
        break if buf.nil?
        unless quiet
          io.print buf
          io.flush
        end
      end
    end
  end
  module_function :cmd

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
  module_function :gem_install

  # pack up the installed gems in +dirname+, to jar file +jarname+
  # 
  # sets $? with that commands return value
  def make_jar(jarname, dirname, quiet = false)
    cmd("jar cf #{jarname} -C #{dirname} .", quiet)
  end
  module_function :make_jar

  # install the bundle, using jruby command +jruby+
  # 
  # sets $? with that commands return value
  def bundle_install(jruby, quiet = false, opts = {})
    ex_opts = opts.map {|k,v| [k,v] }.join(" ")
    cmd("#{jruby} -S bundle install --path ./vendor/bundle/ #{ex_opts}", quiet)
  end
  module_function :bundle_install

  def bundler_vendor_dir(jruby)
    return @bundler_vendor_dir if @bundler_vendor_dir
    sio = StringIO.new
    cmd("#{jruby} -e  '[\"vendor/bundle\",RbConfig::CONFIG[\"ruby_install_name\"], RbConfig::CONFIG[\"ruby_version\"] ].join(\"/\") '",
        false,
        sio)
    @bundler_vendor_dir = sio
  end
  module_function :bundler_vendor_dir

  # run(parse_args("-q","-o",jarname,"-b","Gemfile"))
  def run(opts)
    tmpdir = Dir.mktmpdir
    begin
      cwd = Dir.pwd
      if opts[:bundle]

        b_opts = {}
        b_opts["--with"] = opts[:bundle_with] if opts[:bundle_with]
        b_opts["--without"] = opts[:bundle_without] if opts[:bundle_without]

        begin
          FileUtils.cd tmpdir, :verbose => !opts[:quiet]
          FileUtils.cp opts[:bundle], "Gemfile"

          # If there is a bundler lockfile, then use it too
          if FileTest.file?("#{opts[:bundle]}.lock")
            FileUtils.cp "#{opts[:bundle]}.lock", "Gemfile.lock"

            # ensure these timestamps match the original
            File.utime(File.atime(opts[:bundle]),
                       File.mtime(opts[:bundle]),
                       "Gemfile")
            File.utime(File.atime("#{opts[:bundle]}.lock"),
                       File.mtime("#{opts[:bundle]}.lock"),
                       "Gemfile.lock")

            b_opts["--deployment"] = ""
          end

          bundle_install(opts[:jruby], opts[:quiet], b_opts)
          abort("FAIL: bundler returned: #{$?}") if $? != 0
        ensure
          FileUtils.cd cwd, :verbose => !opts[:quiet]
        end
      end

      opts[:gems].each do |gem|
        gem_install(opts[:jruby], File.join(tmpdir, bundler_vendor_dir(opts[:jruby])), gem, opts[:quiet])
        abort("FAIL: gem install returned: #{$?}") if $? != 0
      end

      # the ./cache/*.gems just duplicates the size of this jar
      unless opts[:cache]
        FileUtils.remove_entry_secure(File.join(tmpdir, bundler_vendor_dir(opts[:jruby]), "cache"), true)
      end

      jarname = opts[:output] ? opts[:output] : File.basename(tmpdir) + ".jar"
      make_jar(jarname, File.join(tmpdir, bundler_vendor_dir(opts[:jruby])), opts[:quiet])
      abort("FAIL: jar packaging returned: #{$?}") if $? != 0

      if opts[:quiet]
        puts jarname
      else
        puts "Created #{jarname}"
      end
    ensure
      # remove the directory.
      FileUtils.remove_entry_secure(tmpdir, true) unless opts[:keep]
    end
  end
  module_function :run

  def main(args)
    o = parse_args(args)
    p o unless o[:quiet]

    run(o)
  end
  module_function :main
end
