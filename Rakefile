#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rake/clean"
require File.expand_path('../lib/gemjar/version', __FILE__)

def git_rev                                                                     
  `git rev-parse --short HEAD`.chomp                                         
end                                                                             

@dist = ENV["dist"] || ".fc16"
@d_dist = " --define 'dist #{@dist}'"
@d_version = " --define 'version #{Gemjar::VERSION}'"
@d_gitrev = "--define 'gitrev #{git_rev}'"

@gemfile = "pkg/gemjar-#{Gemjar::VERSION}.gem" 
@srpmfile = "rpmbuild/SRPMS/jrubygem-gemjar-#{Gemjar::VERSION}-#{git_rev}#{@dist}.src.rpm" 

task :default => :build

desc "Build a SRPM for brew"
task :srpm => [:build] do
  cmd = "rpmbuild -bs --nodeps #{@d_dist} #{@d_version} #{@d_gitrev} --define '_sourcedir ./pkg/' --define '_srcrpmdir rpmbuild/SRPMS' ./jrubygem-gemjar.spec"
  puts cmd
  system cmd
end


desc "Build an RPM (Optional: set 'dist' env)"
task :rpm => [:srpm] do
  cmd = "rpmbuild --rebuild #{@d_dist} #{@d_version} #{@d_gitrev} --define '_rpmdir rpmbuild/RPMS' ./#{@srpmfile}"
  puts cmd
  system cmd
end
