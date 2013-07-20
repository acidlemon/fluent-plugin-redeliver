class Fluent::RedeliverOutput < Fluent::Output
  Fluent::Plugin.register_output('redeliver', self)

  include Fluent::SetTagKeyMixin
  config_set_default :include_tag_key, false

  config_param :regexp, :string, :default => nil
  config_param :replace, :string, :default => nil

  # obsolete option
  config_param :tag_attr, :string, :default => nil

  def initialize
    super
  end

  def configure(conf)
    super

    if tag_attr 
      @include_tag_key = true
      @tag_key = tag_attr
    end
  end

  def start
    super
  end

  def shutdown 
    super
  end

  def emit(tag, es, chain)
    newtag = ''
    if @regexp and @replace
      newtag = tag.sub(Regexp.new(@regexp), @replace)
    end

    if newtag != tag and newtag.length > 0
      es.each do |time, record|
        if (record)
          filter_record(tag, time, record)
          Fluent::Engine.emit(newtag, time, record)
        end
      end
    end

    chain.next
  end  

end

