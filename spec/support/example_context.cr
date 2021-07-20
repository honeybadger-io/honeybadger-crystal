def example_context
  Honeybadger::ContextHash.new.tap do |context|
    context["user_id"] = "23"
    context["public_token"] = "12345abc90"
  end
end
