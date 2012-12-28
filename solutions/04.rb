class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username

  HOSTNAME_REGULAR_EXPRESSION = /(?<host>([0-9a-zA-Z][0-9a-zA-Z-]{,61}[0-9a-zA-Z]\.)+([a-zA-Z]{2,3}(\.[a-zA-Z]{2})?))/
  EMAIL_REGULAR_EXPRESSION = /([0-9a-zA-Z][\w\+\.-]{,200})@#{HOSTNAME_REGULAR_EXPRESSION}/
  EMAIL_PARTITIONAL_USERNAME = /([0-9a-zA-Z][\w\+\.-]{2})([\w\+\.-]{,200})@/
  PHONE_REGULAR_EXPRESSION = /(0|((\+\d{3})|(00\d)))(?<spliter>( |-|\(|\)){,2})(\d\g<spliter>){5,10}\d/
  PHONE_COUNTRY_CODE_REGULAR_EXPRESSION = /((\+\d{3})|(00\d))(?<spliter>( |-|\(|\)){,2})(\d\g<spliter>){5,10}\d/
  PHONE_LOCAL_CODE_REGULAR_EXPRESSION = /0(?<spliter>( |-|\(|\)){,2})(\d\g<spliter>){5,10}\d/

  def initialize(text)
    @preserve_phone_country_code, @preserve_email_hostname, @partially_preserve_email_username = false, false, false
    @text = text
  end

  def filtered
    filtered_emails
    filtered_phones
    @text
  end

  private

  def filter_email
    @text.gsub!(EMAIL_REGULAR_EXPRESSION, '[EMAIL]')
  end

  def filter_username
    @text.gsub!(EMAIL_REGULAR_EXPRESSION, '[FILTERED]@\k<host>')
  end

  def filter_partitional_username
    @text.gsub!(EMAIL_REGULAR_EXPRESSION) { |email| email.gsub(EMAIL_PARTITIONAL_USERNAME, '\1[FILTERED]@') }
  end

  def filter_phone
    @text.gsub!(PHONE_REGULAR_EXPRESSION, '[PHONE]')
  end

  def filter_phone_id
    @text.gsub!(PHONE_COUNTRY_CODE_REGULAR_EXPRESSION) { |phone| phone[0..3]+' [FILTERED]' }
    @text.gsub!(PHONE_LOCAL_CODE_REGULAR_EXPRESSION, '[PHONE]')
  end

  def filtered_emails
    filter_username if preserve_email_hostname
    filter_partitional_username if partially_preserve_email_username
    filter_email if preserve_email_hostname == false and partially_preserve_email_username == false
  end

  def filtered_phones
    filter_phone if @preserve_phone_country_code == false
    filter_phone_id if @preserve_phone_country_code
  end
end

class Validations
  HOSTNAME_REGULAR_EXPRESSION = /([0-9a-zA-Z][0-9a-zA-Z-]{,61}[0-9a-zA-Z]\.)+([a-zA-Z]{2,3}(\.[a-zA-Z][a-zA-Z])?)/
  def self.email?(value)
    /\A[0-9a-zA-Z][\w\+\.-]{,200}@#{HOSTNAME_REGULAR_EXPRESSION}\z/.match(value) ? true : false
  end

  def self.phone?(value)
    /\A(0|((\+\d{3})|(00\d)))(?<spliter>( |-|\(|\)){,2})(\d\g<spliter>){5,10}\d\z/.match(value) ? true : false
  end

  def self.hostname?(value)
    /\A([0-9a-zA-Z][0-9a-zA-Z-]{,61}[0-9a-zA-Z]\.)+([a-zA-Z]{2,3}(\.[a-zA-Z][a-zA-Z])?)\z/.match(value) ? true : false
  end

  def self.ip_address?(value)
    /\A(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).\g<1>.\g<1>.\g<1>\z/.match(value) ? true : false
  end

  def self.number?(value)
    /\A-?(0|[1-9])\d*(\d*|(.?\d+))\z/.match(value) ? true : false
  end

  def self.integer?(value)
    /\A-?\d+\z/.match(value) ? true : false
  end

  def self.date?(value)
    /\A(\d{4})-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\z/.match(value) ? true : false
  end

  def self.time?(value)
    /\A(([01][0-9])|(2[0-3])):[0-5][0-9]:[0-5][0-9]\z/.match(value) ? true : false
  end

  def self.date_time?(value)
    /\A(\d{4})-(\d{2})-(\d{2})( |T)(([01][0-9])|(2[0-3])):[0-5][0-9]:[0-5][0-9]\z/.match(value) ? true : false
  end
end

