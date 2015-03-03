# encoding: utf-8

require 'pathname'
require 'rbconfig'

module Adhearsion
  module ScriptAhnLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) + RbConfig::CONFIG["EXEEXT"]
    SCRIPT_AHN = File.join('script', 'ahn')

    def self.load_script_ahn(path = Dir.pwd)
      path = Pathname.new(path).expand_path
      until path.root?
        if in_ahn_application?(path.to_s)
          load File.join(path, SCRIPT_AHN)
          return true
        end
        path = path.parent
      end
      nil
    end

    def self.in_ahn_application?(path = nil)
      return File.exists? SCRIPT_AHN unless path
      Dir.chdir(path) { return File.exists? SCRIPT_AHN }
    end

    def self.in_ahn_application_subdirectory?(path = nil)
      path = Pathname.new(path.nil? ? Dir.pwd : path)
      File.exists?(File.join(path, SCRIPT_AHN)) ||
        ! path.root? && in_ahn_application_subdirectory?(path.parent)
    end
  end
end
