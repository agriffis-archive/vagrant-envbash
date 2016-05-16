require "pathname"

require "vagrant-envbash/plugin"

module VagrantPlugins
  module EnvBash
    lib_path = Pathname.new(File.expand_path("../vagrant-envbash", __FILE__))
    autoload :Action, lib_path.join("action")
  end
end
