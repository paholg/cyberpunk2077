# Cyberpunk 2077 rebinder

This game does not let you rebind certain keys (such as 'F') by default. WTF.
So this repo includes some remappings to use ESDF instead of WASD for
movement, as well scripts if you'd like to customize them differently.

## Use these bindings

This repo includes the file `inputUserMappings.xml`, which are my custom
bindings. If you run the script to generate your own, it will replace that file.

To use it, locate your Cyberpunk 2077 config directory. For steam, it will be
`Steam/steamapps/common/Cyberpunk 2077/r6/config`.

There will be an existing `inputUserMappings.xml` file there; it is recommended
that you back this file up somewhere.

To use these bindings, simply replace that file with the one from this
repository.

## Customize the bindings

### Requirements

The scripts in this repo require an installation of `ruby`, as well as custom
ruby dependencies.


On windows, you can open a shell in this directory, and run

```
winget install RubyInstallerTeam.Ruby
bundle install
```

### Customize

First, update `map.csv` with your preferred bindings. Then, run `./remap.rb`.
Finally, place `inputUserMappings.xml` in the Cyberpunk 2077 config directory,
as illustrated above.

### Check bindings

The aforementioned script will fail if you replace a binding without setting it
to something else. There is another script to check what a key is bound to.

Run it with `./check.rb <KEY>`. For example, to see the default binding of
'F', run `./check.rb F`.
