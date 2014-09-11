# TM Bundles/Package manager

Install bundle from github easily:

```shell
tmb install elia/avian-missing
```


## Installation

Install with RubyGems in your Terminal:

    gem install tmbundle-manager


## Usage

Use the `tmb` executable:

```shell
$ tmb help
Commands:
  tmb cd PARTIAL_NAME        # open a terminal in the bundle dir
  tmb edit PARTIAL_NAME      # Edit an installed bundle (name will be matched against PARTIAL_NAME)
  tmb help [COMMAND]         # Describe available commands or one specific command
  tmb install USER/BUNDLE    # Install a bundle from GitHub (e.g. tmb install elia/bundler)
  tmb list                   # lists all installed bundles
  tmb path NAME              # print path to bundle dir
  tmb status [BUNDLE]        # Check the status of your local copy of the bundle
  tmb update [PARTIAL_NAME]  # Update installed bundles

```


## Contributing

1. Fork it ( https://github.com/elia/tmbundle-manager/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
