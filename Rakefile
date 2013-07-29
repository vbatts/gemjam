#!/usr/bin/env rake

require "bundler/gem_tasks"
require 'find'
require 'fileutils'
require 'erb'
require "rake/clean"
require File.expand_path('../lib/gemjam/version', __FILE__)

def git_rev
  `git rev-parse --short HEAD`.chomp
end

@dist = ENV["dist"] || ".el6"
@d_dist = " --define 'dist #{@dist}'"

@rpmname = "jrubygem-gemjam"
@gemfile = "pkg/gemjam-#{Gemjam::VERSION}.gem"
@rpmspecfile = "rpmbuild/SPECS/#{@rpmname}.spec"
@srpmfile = "rpmbuild/SRPMS/#{@rpmname}-#{Gemjam::VERSION}-#{git_rev}#{@dist}.src.rpm"

task :default => :build

%w{ ./pkg/ ./rpmbuild/ }.each do |dir|
  if FileTest.directory? dir                                                     
    Find.find(dir) do |path|
      CLEAN.include path if FileTest.file? path
    end
  end
end

desc "RPM spec from erb"
task @rpmspecfile do
  t = ERB.new(File.read("#{@rpmname}.spec.erb"))
  FileUtils.mkdir_p(File.dirname(@rpmspecfile))
  File.open(@rpmspecfile, "w") do |file|
    @version = Gemjam::VERSION
    @gitrev = git_rev()
    file.write(t.result(binding))
  end
end

desc "Build a SRPM for brew"
task :srpm => [@rpmspecfile, :build] do
  cmd = "rpmbuild -bs --nodeps #{@d_dist} --define '_sourcedir ./pkg/' --define '_srcrpmdir rpmbuild/SRPMS' ./#{@rpmspecfile}"
  puts cmd
  system cmd
end


desc "Build an RPM (Optional: set 'dist' env)"
task :rpm => [:srpm] do
  cmd = "rpmbuild --rebuild #{@d_dist} --define '_rpmdir rpmbuild/RPMS' ./#{@srpmfile}"
  puts cmd
  system cmd
end
