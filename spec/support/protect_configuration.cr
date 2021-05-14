require "../spec_helper"

module Honeybadger
  class_setter configuration : Configuration
end

def protect_configuration
  pristine_configuration = Honeybadger.configuration.dup
  yield
  Honeybadger.configuration = pristine_configuration
end

describe "protect_configuration" do
  it "protects the configuration" do
    pristine_configuration = Honeybadger.configuration
    good_key = pristine_configuration.api_key

    protect_configuration do
      bad_key = good_key + "test leakage"
      Honeybadger.configuration.api_key = bad_key
      Honeybadger.api_key.should eq bad_key
    end

    Honeybadger.api_key.should eq good_key
  end
end
