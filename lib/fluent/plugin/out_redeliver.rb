class Fluent::RedeliverOutput < Fluent::Output
  Fluent::Plugin.register_output('redeliver', self)

  config_param :regexp, :string, :default => nil
  config_param :replace, :string, :default => nil

  def initialize
    super
  end

  def configure(conf)
    super
  end

  def start
    super
  end

  def shutdown 
    super
  end

  def emit(tag, es, chain)
    if @regexp and @replace
      newtag = tag.sub(Regexp.new(@regexp), @replace)
    end

    if newtag != tag and newtag.length > 0
      es.each do |time, record|
        Fluent::Engine.emit(newtag, time, record) if record
      end
    end

    chain.next
  end  

end

