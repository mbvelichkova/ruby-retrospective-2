module RegularExpressions
  HOSTNAME      = /(?<hostname>([0-9a-zA-Z][0-9a-zA-Z-]{,61}(?<!\-)\.)+([a-zA-Z]{2,3}(\.[a-zA-Z]{2})?))/
  USERNAME      = /(?<username>([0-9a-zA-Z][\w\+\.-]{,200}))/
  EMAIL         = /\b#{USERNAME}@#{HOSTNAME}\b/
  COUNTRY_CODE  = /(?<country_code>(\+|00)[1-9]\d{,2})/
  PHONE         = /((\b|(?<![\+\w]))(0[^0]|#{COUNTRY_CODE}))([ \-\(\)]{,2}(\d[ \-\(\)]{,2}){6,10}\d)/
  INTEGER       = /-?(0|[1-9]\d*)/
  NUMBER        = /-?((0(\.\d+)?)|[1-9]\d*(\.\d+)?)/
  IP_ADDRESS     = /(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).\g<1>.\g<1>.\g<1>/
  DATE          = /(\d{4})-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])/
  TIME          = /(([01][0-9])|(2[0-3])):[0-5][0-9]:[0-5][0-9]/
end

class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username
  include RegularExpressions

  def initialize(text)
    @preserve_phone_country_code, @preserve_email_hostname, @partially_preserve_email_username = false, false, false
    @text = text
  end

  def filtered
    result = filter_phones(@text)
    filter_emails(result)
  end

  def filter_emails(text)
    if partially_preserve_email_username
      text.gsub(EMAIL) { |string| "#{filter_username($~[:username])}@#{$~[:hostname]}" }
    elsif preserve_email_hostname
      text.gsub(EMAIL, '[FILTERED]@\k<hostname>')
    else
      text.gsub(EMAIL, '[EMAIL]')
    end
  end

  def filter_username(username)
    if username.length >= 6
      username[0..2] + '[FILTERED]'
    else
      '[FILTERED]'
    end
  end

  def filter_phones(text)
    text.gsub(PHONE) do
      if preserve_phone_country_code and $~[:country_code].to_s != ''
        "#{$~[:country_code]} [FILTERED]"
      else
        '[PHONE]'
      end
    end
  end
end

class Validations
  include RegularExpressions

  def self.email?(value)
    /\A#{EMAIL}\z/.match(value) ? true : false
  end

  def self.phone?(value)
    /\A#{PHONE}\z/.match(value) ? true : false
  end

  def self.hostname?(value)
    /\A#{HOSTNAME}\z/.match(value) ? true : false
  end

  def self.ip_address?(value)
    /\A#{IP_ADDRESS}\z/.match(value) ? true : false
  end

  def self.number?(value)
    /\A#{NUMBER}\z/.match(value) ? true : false
  end

  def self.integer?(value)
    /\A#{INTEGER}\z/.match(value) ? true : false
  end

  def self.date?(value)
    /\A#{DATE}\z/.match(value) ? true : false
  end

  def self.time?(value)
    /\A#{TIME}\z/.match(value) ? true : false
  end

  def self.date_time?(value)
    /\A#{DATE}( |T)#{TIME}\z/.match(value) ? true : false
  end
end

