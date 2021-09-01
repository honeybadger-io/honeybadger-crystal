require "../spec_helper"

describe Honeybadger::Context do
  before_each do
    # also tests that a context can be cleared
    Honeybadger::Context.current.clear
  end

  it "allows creating a context from a hash" do
    hash_context = {
      "user_id" => 3
    }

    context = Honeybadger::Context.new(hash_context)
    context["user_id"].should eq(hash_context["user_id"].to_s)
  end

  it "can pull a context from the fiber" do
    Honeybadger::Context.current.should be(Fiber.current.honeybadger_context)
  end

  it "can store arbitrary keys and values into the context" do
    Honeybadger.context(user_id: 45)
    Honeybadger::Context.current["user_id"].should eq "45"
  end

  it "can merge a Log::Metadata context in" do
    context = Honeybadger::Context.new
    log_metadata = Log::Metadata.build({user_id: 126})
    context["user_id"]?.should be_nil
    context.merge log_metadata
    context["user_id"].should eq "126"
  end

  it "can merge another Context in" do
    context_1 = Honeybadger::Context.new
    context_2 = Honeybadger::Context.new

    context_1["user_id"] = "228"
    context_2["shopping_cart_total"] = "48"

    context_2.merge context_1
    context_2["shopping_cart_total"].should eq "48"
    context_2["user_id"].should eq "228"
  end

  it "allows retrieving the current context" do
    Honeybadger.context.should be_a Honeybadger::Context
  end
end
