# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::PubSub::Subscription, :attributes, :mock_pubsub do
  let(:labels) { { "foo" => "bar" } }
  let(:topic_name) { "topic-name-goes-here" }
  let(:dead_letter_topic_path) { topic_path("topic-name-dead-letter") }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name, labels: labels, dead_letter_topic: dead_letter_topic_path, max_delivery_attempts: 6 }
  let(:sub_deadline) { sub_hash[:ack_deadline_seconds] }
  let(:sub_endpoint) { sub_hash[:push_config][:push_endpoint] }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "gets topic from the Google API object" do
    # No mocked service means no API calls are happening.
    subscription.topic.must_be_kind_of Google::Cloud::PubSub::Topic
    subscription.topic.must_be :reference?
    subscription.topic.wont_be :resource?
    subscription.topic.name.must_equal topic_path(topic_name)
  end

  it "gets deadline from the Google API object" do
    subscription.deadline.must_equal sub_deadline
  end

  it "gets retain_acked from the Google API object" do
    assert subscription.retain_acked
  end

  it "gets its retention from the Google API object" do
    subscription.retention.must_equal 600.9
  end

  it "gets endpoint from the Google API object" do
    subscription.endpoint.must_equal sub_endpoint
  end

  it "can update the endpoint" do
    new_push_endpoint = "https://foo.bar/baz"
    push_config = Google::Cloud::PubSub::V1::PushConfig.new(push_endpoint: new_push_endpoint)
    mpc_res = nil
    mock = Minitest::Mock.new
    mock.expect :modify_push_config, mpc_res, [subscription_path(sub_name), push_config, options: default_options]
    pubsub.service.mocked_subscriber = mock

    subscription.endpoint = new_push_endpoint

    mock.verify
  end

  it "gets expires_in from the Google API object" do
    two_days_seconds = 60*60*24*2
    subscription.expires_in.must_equal two_days_seconds
  end

  it "gets push_config from the Google API object" do
    subscription.push_config.must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig
    subscription.push_config.endpoint.must_equal sub_endpoint
    subscription.push_config.authentication.must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig::OidcToken
    subscription.push_config.authentication.email.must_equal "user@example.com"
    subscription.push_config.authentication.audience.must_equal "client-12345"
    subscription.push_config.must_be :oidc_token?
  end

  it "gets labels from the Google API object" do
    subscription.labels.must_equal labels
  end

  it "gets dead_letter_topic from the Google API object" do
    subscription.dead_letter_topic.name.must_equal dead_letter_topic_path
  end

  it "gets dead_letter_max_delivery_attempts from the Google API object" do
    subscription.dead_letter_max_delivery_attempts.must_equal 6
  end

  describe "reference subscription object of a subscription that does exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "makes an HTTP API call to retrieve topic" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.topic.must_be_kind_of Google::Cloud::PubSub::Topic

      mock.verify

      subscription.topic.must_be :reference?
      subscription.topic.wont_be :resource?
      subscription.topic.name.must_equal topic_path(topic_name)
    end

    it "makes an HTTP API call to retrieve deadline" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.deadline.must_equal sub_deadline

      mock.verify
    end

    it "makes an HTTP API call to retrieve retain_acked" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      assert subscription.retain_acked

      mock.verify
    end

    it "makes an HTTP API call to retrieve endpoint" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.endpoint.must_equal sub_endpoint

      mock.verify
    end

    it "makes an HTTP API call to retrieve expires_in" do
      two_days_seconds = 60*60*24*2

      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.expires_in.must_equal two_days_seconds

      mock.verify
    end

    it "makes an HTTP API call to retrieve labels" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, labels: labels)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.labels.must_equal labels

      mock.verify
    end

    it "makes an HTTP API call to retrieve dead_letter_topic and dead_letter_max_delivery_attempts" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, dead_letter_topic: dead_letter_topic_path, max_delivery_attempts: 7)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.dead_letter_topic.name.must_equal dead_letter_topic_path
      subscription.dead_letter_max_delivery_attempts.must_equal 7

      mock.verify
    end

    it "makes an HTTP API call to retrieve labels" do
      get_res = Google::Cloud::PubSub::V1::Subscription.new subscription_hash(topic_name, sub_name, labels: labels)
      mock = Minitest::Mock.new
      mock.expect :get_subscription, get_res, [subscription_path(sub_name), options: default_options]
      subscription.service.mocked_subscriber = mock

      subscription.labels.must_equal labels

      mock.verify
    end

    it "does not make an HTTP API call to access push_config" do
      subscription.push_config.must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig
      subscription.push_config.endpoint.must_be :empty?
      subscription.push_config.authentication.must_be :nil?
    end
  end

  describe "reference subscription object of a subscription that does not exist" do
    let :subscription do
      Google::Cloud::PubSub::Subscription.from_name sub_name,
                                            pubsub.service
    end

    it "raises NotFoundError when retrieving topic" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.topic
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving deadline" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.deadline
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving endpoint" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.endpoint
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving expires_in" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.expires_in
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving labels" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.labels
      end.must_raise Google::Cloud::NotFoundError
    end

    it "does not raise NotFoundError when accessing push_config" do
      subscription.push_config.must_be_kind_of Google::Cloud::PubSub::Subscription::PushConfig
      subscription.push_config.endpoint.must_be :empty?
      subscription.push_config.authentication.must_be :nil?
    end

    it "raises NotFoundError when retrieving dead_letter_topic" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.dead_letter_topic
      end.must_raise Google::Cloud::NotFoundError
    end

    it "raises NotFoundError when retrieving dead_letter_max_delivery_attempts" do
      stub = Object.new
      def stub.get_subscription *args
        gax_error = Google::Gax::GaxError.new "not found"
        gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
        raise gax_error
      end
      subscription.service.mocked_subscriber = stub

      expect do
        subscription.dead_letter_max_delivery_attempts
      end.must_raise Google::Cloud::NotFoundError
    end
  end
end
