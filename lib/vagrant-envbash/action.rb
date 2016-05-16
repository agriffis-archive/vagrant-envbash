module VagrantPlugins
  module EnvBash
    module Action
      class LoadEnvBash
        def initialize(app, env)
          # This method is defined to avoid a stack trace if it doesn't exist.
          # We have no real need to save @app
          @app = app
        end

        def call(env)
          # Note that this loads early enough that there's no env[:ui] yet for
          # outputting informational messages. Use the "vagrant env" command
          # instead to investigate.

          # The passed `env` is a wrapper around the env we want.
          e = env[:env]

          # This plugin will can be called multiple times, especially when
          # operating on ids, for example "vagrant status 0fb925d". Don't try to
          # load env.bash until we have a root path, and don't load twice.
          return unless e.root_path
          begin
            return if e.envbash_ran
          rescue
            class << e
              attr_accessor :envbash_ran, :envbash_file, :envbash_loaded,
                            :envbash_before, :envbash_after
            end

            # Avoid running twice.
            e.envbash_ran = true

            # We haven't loaded yet.
            e.envbash_file = nil
            e.envbash_loaded = false

            # Save the original ENV for comparison in "vagrant env"
            e.envbash_before = ENV.to_h
          end

          # Try to find env.bash, since it will be adjacent to Vagrantfile.
          keep_vagrant_envbash_file = !! ENV['VAGRANT_ENVBASH_FILE']
          if ! keep_vagrant_envbash_file
            ENV['VAGRANT_ENVBASH_FILE'] = (e.root_path + 'env.bash').to_s
          end
          e.envbash_file = ENV['VAGRANT_ENVBASH_FILE']

          # Load env.bash. This runs bash inside %x because Ruby uses /bin/sh
          # for backticks.
          new_env = eval %x{bash -c '
            if [[ -s $VAGRANT_ENVBASH_FILE ]]; then
              source "$VAGRANT_ENVBASH_FILE"
            fi
            ruby -e "p ENV"
          '}

          # Ignore modification to SHLVL which is just a shell artifact.
          if e.envbash_before['SHLVL']
            new_env['SHLVL'] = e.envbash_before['SHLVL']
          else
            new_env.delete('SHLVL')
          end

          # Replace the entire ENV (rather than update) so that env.bash can
          # both set and unset vars.
          ENV.replace(new_env)

          # We are loaded!
          e.envbash_loaded = true

          # Remove VAGRANT_ENVBASH_FILE from ENV if we set it.
          ENV.delete('VAGRANT_ENVBASH_FILE') unless keep_vagrant_envbash_file

          # Save the new ENV for comparison in "vagrant env"
          e.envbash_after = ENV.to_h
        end
      end
    end
  end
end
