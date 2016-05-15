## Usage

*Note: This is very much a work-in-progress right now, so if you use it, expect that it will break and/or not work for your use cases.*

So far, `gf` (and its derivatives, `<c-w>f`, etc.) works, for particular
patterns:

- In the routes file, `gf` on a route opens up the relevant file
- In templates, `gf` on a component opens up the main component file
- `gf` on any `get('serviceName.something')` will open the service
  `service-name` (if it's been injected).
- Also, on the `serviceName: Ember.inject.service()` line, `gf` on serviceName
  will work
- `gf` on a file-relative import, say `../../mixins/foobar`, works correctly
- `gf` on `createRecord`, `belongsTo`, and a few other things send you to the model

The other big thing you can do is use the `:Extract <component-name>` command to extract a template partial into its own component.

Works well with [projectionist](https://github.com/tpope/vim-projectionist)
and a custom projections file: https://gist.github.com/AndrewRadev/3524ee46bca8ab349329

## TODO/Ideas

- Integrate projections automatically somehow?
- Make the patterns more generic, so they capture stuff from many places in the line
- Get it to play nicely with rails.vim (remap `<Plug><cfile>`)

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/ember-tools.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
