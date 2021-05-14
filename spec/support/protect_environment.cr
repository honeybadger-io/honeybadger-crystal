require "../spec_helper"

def protect_env
  pristine_environment = ENV.to_h

  yield

  (ENV.keys - pristine_environment.keys).each do |unwanted_key|
    ENV.delete unwanted_key
  end

  pristine_environment.each do |key, value|
    ENV[key] = value
  end
end

describe "protect_env" do
  it "restores the values for keys which used to be in the env" do
    test_key = "hb_env_test_key"
    test_value = "fizzbuzz"
    wrong_value = "foobar"

    ENV[test_key] = test_value

    protect_env do
      ENV[test_key] = wrong_value
      ENV[test_key].should eq wrong_value
    end

    ENV[test_key].should eq test_value

    # manually protect the environment from getting polluted by this test
    ENV.delete test_key
  end

  it "removes keys that don't belong" do
    test_key = "env_protect_should_remove_this_key"
    ENV[test_key]?.should be_nil

    protect_env do
      ENV[test_key] = "0"
      ENV[test_key]?.should_not be_nil
    end

    ENV[test_key]?.should be_nil
  end
end
