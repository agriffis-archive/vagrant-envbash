begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant EnvBash plugin must be run within Vagrant."
end

module VagrantPlugins
  module EnvBash
    class Plugin < Vagrant.plugin("2")
      name "EnvBash"
      description <<-DESC
      This plugin loads environment from env.bash.
      DESC

      # Hook as early as possible to load env.bash.
      # This is the earliest hook that's publicly documented (and might be the
      # earliest hook anyway).
      action_hook(:load_env_bash, :environment_plugins_loaded) do |hook|
        hook.prepend(VagrantPlugins::EnvBash::Action::LoadEnvBash)
      end

      # Register the "vagrant env" command which can list the full or partial
      # environment.
      command "env" do
        require_relative "command"
        EnvCommand
      end
    end
  end
end
