## Usage

*Note: This is **very** work-in-progress right now, so if you use it, expect that it will break and/or not work for your use cases.*

So far, the only thing that works is `gf` (and its derivatives, `<c-w>f`,
etc), for particular patterns, and only in coffeescript and emblem:

- In the routes file, `gf` on a route opens up the relevant file
- In templates, `gf` on a component opens up the main component file
- `gf` on any `@get('serviceName.something')` will open the service
  `service-name` (if it's been injected).
- Also, on the `serviceName: Ember.service.inject()` line, `gf` on serviceName
  will work
- `gf` on a file-relative import, say `../../mixins/foobar`, works correctly

Works well with [projectionist](https://github.com/tpope/vim-projectionist)
and a custom projections file: https://gist.github.com/AndrewRadev/3524ee46bca8ab349329

## TODO/Ideas

- `gf` on `createRecord`, `findRecord`, etc. can easily open models
- `:Extract component-name` that takes a visual selection and puts it in a
  component (try to parse property bindings or keep it simple?)
- Integrate projections automatically somehow?
- Make it more generic, so that it works for plain js and hbs

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/ember-tools.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
