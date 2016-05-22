## Usage

This plugin contains various tools to work with ember.js projects. After installing it, just editing files in an ember.js project should be enough to activate them. It's similar to (and inspired by) [rails.vim](https://github.com/tpope/vim-rails).

The tools work both for javascript and coffeescript, and they support both the handlebars and emblem templating languages.

It's recommended to also use the [vim-projectionist](https://github.com/tpope/vim-projectionist) plugin for easier navigation through the project. Here's a sample json file you might use with it: https://gist.github.com/AndrewRadev/3524ee46bca8ab349329. It sets up the major file types you might want to navigate to, and it connects routes, controllers, and templates, so that the `:A` command jumps from route to controller, to template, and then back to the route.

A list of the different tools that the plugin provides follows.

### gf

This plugin sets a special `includeexpr` that does a good job of locating files based on contextual information. This includes not only `gf`, but the entire family of mappings that depends on `includeexpr`, like `<c-w>f`. From now on, for clarity, only "gf" will be used.

#### gf: Routes

Pressing `gf` on a route in the `app/routes.js` file will open the relevant route file. This attempts to respect nesting as well, so as long as your routes don't do anything too fancy, the plugin will probably manage to find out where it's supposed to go. For example:

``` javascript
Router.map(function() {
  this.route('foo', function() {
    this.route('bar-baz');
  })
});
```

Pressing `gf` on "bar-baz" will jump to "app/routes/foo/bar-baz.js", provided that file exists.

#### gf: Components in templates

Pressing `gf` on a component name in a template files will jump to that component's template. For example:

``` handlebars
<header>
  {{header-navigation user=currentUser}}
</header>
```

Pressing `gf` while on "header-navigation" will jump to "app/components/header-navigation/template.hbs", or "app/templates/components/header-navigation.hbs", if any of those files exists.

#### gf: Actions in templates

Pressing `gf` on an action name in a template files will jump to the current template's controller or component, and jump to the particular action. So, having a file like this:

``` handlebars
<header>
  {{header-navigation onHover=(action 'showTooltip')}}
</header>
```

Pressing `gf` while on "showTooltip" will jump to the current template's controller/component file and find the "showTooltip" action.

#### gf: Services

If you have a service defined in the file "app/services/cookie-settings.js", then you can jump to that file while hitting `gf` on the point of injection of the service:

``` javascript
import Ember from 'ember';

export default Ember.Service.extend({
  cookieSettings: Ember.inject.service()
  // ...
});
```

A `gf` on "cookieSettings" will jump to the right file, if it exists. If you invoke the service with `this.get`, you can also `gf` there as well:

``` javascript
this.get('cookieSettings.someProperty');
```

A `gf` on "cookieSettings" in the `get` will also work, as long as there's an injection line in the file.

#### gf: Models

If you have a method call that is related to a model, then a `gf` on it will jump to that model. For instance,

``` javascript
export default Ember.Model.extend({
  user: DS.belongsTo("user")
});
```

A `gf` on the "user" in the `belongsTo` call will jump to the user model, if it exists. The method calls that work this way are:

- `createRecord`
- `modelFor`
- `belongsTo`
- `hasMany`

#### gf: Imports

If you have a relative import line, like this:

``` javascript
import Ember from 'ember';
import ControllerCommonMixin from '../../mixins/controller-common';

export default Ember.Controller.extend(ControllerCommonMixin)
```

Using `gf` on "../../mixins/controller-common" will send you to the right file, relative to the current one.

### :Extract

The `:Extract` command is invoked on a range of lines, usually in visual mode. It's only defined in templating languages (handlebars or emblem). It takes the selected lines and moves them to a separate component's template. It also creates a placeholder component file for them.

So, if you have a template that looks like this:

``` handlebars
<header>
  <ul>
    <li>{{#link-to 'index'}}Home{{/link-to}}</li>
    <li>{{#link-to 'login'}}Login{{/link-to}}</li>
  </ul>
</header>
```

You can mark everything within the `<header>` tag and execute this command:

``` vim
:Extract header-navigation
```

This will create the following files:

- `app/components/header-navigation/component.js`
- `app/components/header-navigation/template.hbs`

The original template will now look like this:

``` handlebars
<header>
  {{header-navigation}}
</header>
```

And the header-navigation template file will be opened in a split window and will contain:

``` handlebars
<ul>
  <li>{{#link-to 'index'}}Home{{/link-to}}</li>
  <li>{{#link-to 'login'}}Login{{/link-to}}</li>
</ul>
```

If the original template is an emblem one, the component will also have an emblem template, but if you'd like to specify explicitly what templates you prefer, set the `g:ember_tools_default_logic_filetype` and/or `g:ember_tools_default_template_filetype` configuration variables.



## Settings

``` vim
let g:ember_tools_default_logic_filetype = 'coffee'
```

Default value: javascript

This variable controls the default logic filetype the plugin will use. In general, it'll try to use the same filetype as the current file (javascript or coffeescript), but in situations when it can't guess, it'll read this variable to find the "default" preference.

``` vim
let g:ember_tools_default_template_filetype = 'emblem'
```

Default value: handlebars

This variable controls the default template filetype the plugin will use. In general, it'll try to use the same filetype as the current file (handlebars or emblem), but in situations when it can't guess, it'll read this variable to find the "default" preference.

``` vim
let g:ember_tools_custom_gf_callbacks = ['SomeFunctionName']
```
Default value: []

This variable allows the user to set up custom callbacks for the `gf` mapping. It should be a list of function names. The plugin will call those without any arguments, in order, and if any of them return anything that's not an empty string, it'll stop execution and use that as the result.

The current directory for the duration of the callback will be the ember root. Also, at this time, the `iskeyword` parameter will be set to include the "." and "/" characters, in order to make it easier to match some ember identifiers. Feel free to change it in your callbacks, it will be reset once the callback is done.

An example of what you could potentially do can be found in this gist: https://gist.github.com/AndrewRadev/c62132f96deca165b8969eba7bc1dc13

There's quite a few project-specific things, which is why it's not a general-purpose callback. There's also a few invocations of the plugin's public API, which, unfortunately, you would have to read the source code to understand.

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/ember-tools.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
