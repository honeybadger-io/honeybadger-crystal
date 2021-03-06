require "./honeybadger/*"

module Honeybadger
  VERSION = "0.1.0"

  @@api_key = ""

  def self.configure(api_key : String) : Nil
    @@api_key = api_key
  end

  def self.api_key
    @@api_key
  end
end
