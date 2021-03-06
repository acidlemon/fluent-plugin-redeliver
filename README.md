# Fluent::Plugin::Redeliver

Simple re-delivery plugin to process log record as another tag

## Synopsis

### Basic

```
<match foo.**>
  type     redeliver
  regexp   ^foo\.(.*)$
  replace  bar.\1
  # add original tag to record['__tag'] (optional) 
  include_tag_key true
  tag_key __tag
</match>

<match bar.**>
  # write your output process

</match>
```

For v0.0.2 User: `tag_attr` is obsoleted. But it works compatible with 0.0.2 now.

### More Effective

```
<match myapp.error.*>
  type copy

  <store>
    type file
    path /path/to/file
  </store>

  <store>
    type     redeliver
    regexp   ^myapp\.error\.(.*)$
    replace  logging.error.\1
    include_tag_key true
    tag_key __tag
  </store>
</match>

<match logging.error.*>
  type copy
  
  # store all logs
  <store>
    type mongo
    host remotehost
    database fluent
    collection errorlog
  </store>

  # and suppress log and notify... (using fluent-plugin-suppress)
  <store>
    type           suppress
    interval       10
    num            2
    attr_keys      message
    add_tag_prefix sp.
  </store>  
</match>

# write <match sp.logging.error.*> for notify...
# write <match logging.**> for mongo...
  :
  :
```


## Configuration

 * `regexp`: redelivers the record if tag matches specified pattern.
 * `replace`: rewrites tag for re-emit. You can use n-th matched subexpression(\1,\2...) for replace string.
 * `include_tag_key`: enables adding original tag to specified key when regexp matches.
 * `tag_key`: adds original tag to specified key when include_tag_key set `true`.


## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-redeliver'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-redeliver

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


