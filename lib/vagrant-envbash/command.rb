class EnvCommand < Vagrant.plugin(2, :command)
  def execute
    begin
      @env.envbash_ran
    rescue
      @env.ui.error "vagrant-envbash plugin did not load! Do you have a Vagrantfile?"
      return 2
    end

    if ! @env.envbash_loaded
      @env.ui.warn "vagrant-envbash couldn't load #{@env.envbash_file.inspect}"
      return 1
    end

    #@env.ui.info "vagrant-envbash loaded #{@env.envbash_loaded.inspect}"

    before, after = @env.envbash_before, @env.envbash_after
    added = after.to_a.select {|k, v| ! before.has_key? k}
    removed = before.to_a.select {|k, v| ! after.has_key? k}
    changed = after.to_a.select {|k, v| before.has_key? k and before[k] != v}

    if ! changed.empty?
      @env.ui.info "CHANGED the following variables:"
      changed.each do |k, v|
        @env.ui.info "    #{k}=#{v.inspect} (was: #{before[k].inspect})"
      end
    end

    if ! added.empty?
      @env.ui.info "ADDED the following variables:"
      added.each do |k, v|
        @env.ui.info "    #{k}=#{v.inspect}"
      end
    end

    if ! removed.empty?
      @env.ui.info "REMOVED the following variables:"
      removed.each do |k, v|
        @env.ui.info "    #{k}=#{v.inspect}"
      end
    end

    if added.empty? && removed.empty? && changed.empty?
      @env.ui.info "NOTHING added, removed or changed."
    end

    0
  end
end
