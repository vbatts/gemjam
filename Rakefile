#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rake/clean"
require File.expand_path('../lib/gemjar/version', __FILE__)

@dist = ENV["dist"] || ".fc16"
@gemfile = "pkg/gemjar-#{Gemjar::VERSION}.gem" 
@srpmfile = "rpmbuild/SRPMS/jrubygem-gemjar-#{Gemjar::VERSION}-1#{@dist}.src.rpm" 
@d_dist = " --define 'dist #{@dist}'"
@d_version = " --define 'version #{Gemjar::VERSION}'"

task :default => :build

desc "Build a SRPM for brew"
task :srpm => [:build] do
  cmd = "rpmbuild -bs --nodeps #{@d_dist} #{@d_version} --define '_sourcedir ./pkg/' --define '_srcrpmdir rpmbuild/SRPMS' ./jrubygem-gemjar.spec"
  puts cmd
  system cmd
end


desc "Build an RPM (Optional: set 'dist' env)"
task :rpm => [:srpm] do
  cmd = "rpmbuild --rebuild #{@d_dist} #{@d_version} --define '_rpmdir rpmbuild/RPMS' ./#{@srpmfile}"
  puts cmd
  system cmd
end
