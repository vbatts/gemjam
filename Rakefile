#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/clean"

task :default => :build

desc "Build a SRPM for brew"
task :srpm => [:build] do
  define_dist=" --define 'dist #{ENV["dist"]}' " if ENV["dist"]
  puts `rpmbuild -bs --nodeps #{define_dist} --define "_sourcedir ./pkg/" --define "_srcrpmdir rpmbuild/SRPMS" ./jrubygem-gemjar.spec`
end


desc "Build an RPM (set 'dist' env if needed"
task :rpm => [:srpm] do
  define_dist=" --define 'dist #{ENV["dist"]}' " if ENV["dist"]
  srpm_file = `ls -1rt rpmbuild/SRPMS/*.src.rpm`.split("\n").last
  puts `rpmbuild --rebuild #{define_dist} --define "_rpmdir rpmbuild/RPMS" ./#{srpm_file}`
end
