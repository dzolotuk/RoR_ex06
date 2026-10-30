# Rails 7.0.6 gives the option `quirks_mode` to the json gem, and json 2.10 or newer
# refuses it ("ArgumentError: unknown keyword: quirks_mode"; it broke the session and
# the flash). Rails 7.0.8.7 and newer do not send it any more. Until the Rails of the
# project is that new, the option is dropped here: it did nothing in the json gem anyway.
# The other arguments are passed on as they came, so it works with every version of json.
module JsonWithoutQuirksMode
  def parse(source, *args, **options)
    super(source, *args, **options.except(:quirks_mode))
  end

  def generate(object, *args, **options)
    super(object, *args, **options.except(:quirks_mode))
  end
end

JSON.singleton_class.prepend(JsonWithoutQuirksMode)
