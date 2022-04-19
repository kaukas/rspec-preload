# rspec-preload

rspec-preload is a short script that does the easy 70% of tools like spring and zeus. In addition to that, it runs `before(:suite)` hooks once.

## Why?

[Read the related blog entry.](https://kaukas.mataroa.blog/blog/rspec-preloader/)

I've tried spring before. For some reason it sometimes failed to pick up file changes, and at other times consumed 100% CPU, even when sleeping. For all I know, [these problems could be solved by now](https://github.com/rails/spring/issues/636) but were serious enough back then.

In addition, I worked on projects that performed slow DB cleanup tasks on startup. Even spring could not help with those (could it?).

And so I thought "how hard can it be" and scratched my own itch.

## WARNING

This is a hack, for many reasons:

- It peeks deep into RSpec internals. Those could change at any time. Works only on RSpec 3.
- It preloads `spec_helper.rb` and `rails_helper.rb`. Whatever files get required will never be reloaded. Gems, Rails configuration, initializers, and whatever they require will not be reloaded, and you will get no warnings. If you change those files you'll have to restart the preloader to pick the changes up. That said, most of the things in Rails are auto-loaded. Since specs are run in a subprocess, spec code and anything it depends on gets thrown away after each run, to be loaded on the next again.
- Only FactoryBot factories get reloaded. Because that was easy.
- [I've had crashes when forking on newer Macs and Rails](https://stackoverflow.com/q/52941426). `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` helped.

## Install

It is not meant to be installed in the normal sense. Copy `bin/rspec_preload.rb` to your scripts folder. Or clone this repo.

## Run

```ruby
$ bundle exec ruby ./path/to/rspec_preload.rb
(rspec_preload) $
```

Now you can type in your rspec command as usual:

```ruby
$ bundle exec ruby ./path/to/rspec_preload.rb
(rspec_preload) $ rspec spec/my_spec.rb
....
Finished in ... seconds ()
```

One caveat: bare `rspec` picks up no specs rather than all specs. You can pass the spec folder as a parameter to run all specs:

```ruby
$ bundle exec ruby ./path/to/rspec_preload.rb
(rspec_preload) $ rspec
No examples found.

(rspec_preload) $ rspec spec
....
Finished in ... seconds ()
```

You can prepend it with `bundle exec`, or anything else really; anything before the first `rspec` will be thrown away:

```ruby
$ bundle exec ruby ./path/to/rspec_preload.rb
(rspec_preload) $ bundle exec rspec spec/my_spec.rb
....
Finished in ... seconds ()
```

The command input uses Ruby `gets` which is not human friendly. [You can use `rlwrap`](https://github.com/hanslub42/rlwrap) to add normal input navigation, history, etc:

```ruby
$ rlwrap bundle exec ruby ./path/to/rspec_preload.rb
(rspec_preload) $ rspec spec/my_spec.rb
....
Finished in ... seconds ()
```

## Maintenance

No guarantees. It might break, it might lie to you (it probably will!), it might brick your computer. Use at your own risk.

In any case, if you use it do first understand what it does. You have been warned.

## Prior Art

I found [rspec-preloader](https://github.com/victormours/rspec-preloader). I should have searched earlier. It is neat; it tracks file changes and reloads them. But it does not load `rails_helper.rb` nor run `before(:suite)` hooks. Alternatives FTW!
