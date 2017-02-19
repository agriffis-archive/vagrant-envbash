# DEPRECATED! Use [envbash](https://github.com/scampersand/envbash-ruby) instead.

# Vagrant envbash plugin

This is a [Vagrant](http://www.vagrantup.com) plugin to load environment
variables from `env.bash`. Putting settings in `env.bash` provides a single
source of development configuration for Vagrant (e.g. AWS secrets that shouldn't
be committed to source control) and the application under development. This is
especially important for web apps that adhere to the
[twelve-factor methodology](http://12factor.net/).

This plugin was inspired by [vagrant-env](https://github.com/gosuri/vagrant-env)
with the primary difference that `env.bash` is a proper Bash script that will be
executed by `/bin/bash`, so it can contain conditionals, multi-line strings,
etc. This also makes it easier to source into the shell in the Vagrant guest as
application configuration.

This plugin also adds a command `vagrant env` to inspect how `env.bash` modifies
the environment.

## Installation

Install using Vagrant's plugin system:

```
vagrant plugin install vagrant-envbash
```

## Usage

With the plugin installed, Vagrant will look for `env.bash` in the same
directory as `Vagrantfile`. If found, Vagrant will execute the file as a Bash
script. Any environment variables that are exported in the file will be updated
in `ENV`. Additionally any variables that are unset will be removed from `ENV`.

The plugin runs very early in the Vagrant execution, so `ENV` is fully updated
before executing configuration in `Vagrantfile`. This means that `env.bash` is
the ideal place to put development configuration such as AWS secrets for
[vagrant-aws](https://github.com/mitchellh/vagrant-aws) that shouldn't be
committed to source control in Vagrantfile.

## Examples

### Example of AWS secrets in `env.bash`

With this `Vagrantfile`:

```
Vagrant.configure("2") do |config|
  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.ami = ENV.fetch('AWS_AMI', "ami-7747d01e")
  end
end
```

then the secrets can be put into `env.bash`:

```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=yyyyyyyyyyyyyyyyyy
export AWS_KEYPAIR_NAME=email@example.com
```

Additionally if the `Vagrantfile` has multiple provider configuration stanzas to
enable a large developer organization, then the developer can choose their
preferred provider on a per-project basis by setting `VAGRANT_DEFAULT_PROVIDER`
in `env.bash`:

```
export VAGRANT_DEFAULT_PROVIDER=aws
```

### Trivial example of `vagrant env`

With this initial environment configuration:

```
$ export W=unmodified
$ export X=unmodified
$ # Y is not set
$ export Z=unmodified
```

And this `env.bash`:

```
export W=unmodified
export X=modified
export Y=added
unset Z  # remove from ENV
```

Then we can run `vagrant env` to see what happens:

```
$ vagrant env
CHANGED the following variables:
    X="modified" (was: "unmodified")
ADDED the following variables:
    Y="added"
REMOVED the following variables:
    Z="unmodified"
```

## FAQ

### Should I commit `env.bash` to source control?

No, definitely not. The purpose of `env.bash` is to store development
configuration that isn't suitable for committing to the repository, whether
that's secret keys or developer-specific customizations. In fact, you should add
the following line to `.gitignore`:

```
/env.bash
```

### Is it necessary to explicitly `export` variables in `env.bash`?

Yes. If you have a lot of settings and want to avoid repeating `export`, you can
put `set -a` at the top of your `env.bash` to automatically export all
variables. In that case, you should also `set +a` at the bottom to avoid
confusion if you source `env.bash` into your guest shell configuration.

### How do I put a multi-line string into `env.bash`?

You can put newlines directly into a multi-line string in Bash, so for example
this works:

```
export PRIVATE_KEY="
-----BEGIN RSA PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END RSA PRIVATE KEY-----"
```

### Can I remove settings from the environment?

Yes, anything you `unset` will be removed from `ENV`. See the example of
`vagrant env` above.

### How do I source `env.bash` into my guest shell environment?

Assuming that your source directory is available on the default `/vagrant` mount
point in the guest, you can simply add a line at the bottom of
`/home/vagrant/.bash_profile`:

```
source /vagrant/env.bash
```

Note that this means that settings are loaded on `vagrant ssh` so you need to
exit the shell and rerun `vagrant ssh` to refresh if you change settings.
