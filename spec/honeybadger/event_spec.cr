require "../spec_helper"

record ExampleEventProperty, id : Int32

module Honeybadger
  describe Event do
    it "sets a timestamp" do
      event = Event.new

      event.timestamp.should be_a Time
      event.to_json.should contain %{"ts":"#{event.timestamp.to_rfc3339(fraction_digits: 3)}"}
    end

    it "can have its timestamp set explicitly" do
      ts = 1.second.ago

      Event.new(ts).timestamp.should eq ts
    end

    it "can have properties set" do
      event = Event.new

      event["name"] = "foo"

      event.to_json.should contain %{"name":"foo"}
    end

    it "can have properties set at instantiation time" do
      event = Event.new(name: "foo")

      event.to_json.should contain %{"name":"foo"}
    end

    it "converts array properties" do
      event = Event.new(ids: [1, 2, 3])

      event.to_json.should contain %{"ids":[1,2,3]}
    end

    it "converts nested array properties" do
      event = Event.new(matrix: [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ])

      event.to_json.should contain %{"matrix":[[1,2,3],[4,5,6],[7,8,9]]}
    end

    it "converts hash properties" do
      event = Event.new(user: {"id" => 1})

      event.to_json.should contain %{"user":{"id":1}}
    end

    it "converts nested hash properties" do
      event = Event.new(order: {"address" => {"zip" => "12345"}})

      event.to_json.should contain %{"order":{"address":{"zip":"12345"}}}
    end

    it "converts URIs" do
      event = Event.new(url: URI.parse("https://example.com"))

      event.to_json.should contain %{"url":"https://example.com"}
    end

    it "converts arbitrary objects into their text representation" do
      event = Event.new(
        property: ExampleEventProperty.new(id: 123),
      )

      serialized = event.to_json

      serialized.should contain %{"property":"ExampleEventProperty(@id=123)"}
    end

    it "can delete properties from the event" do
      event = Event.new(one: 1, two: "two")
      event["one"]?.should eq 1

      event.delete "one"
      event["one"]?.should eq nil
    end

    it "merges two events together" do
      first = Event.new(id: 123, name: "first")
      second = Event.new(name: "second")

      data = first.merge(second).to_json

      # Uses the first event's timestamp
      data.should contain %{"ts":"#{first.timestamp.to_rfc3339(fraction_digits: 3)}"}
      data.should contain %{"id":123}
      # The second event's non-timestamp properties override that of the first
      data.should contain %{"name":"second"}
    end

    it "can take hashes in the constructor" do
      event = Event.new({"foo" => "bar"})

      event["foo"].should eq "bar"
    end
  end
end
