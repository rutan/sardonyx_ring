# frozen_string_literal: true

module SardonyxRing
  module Services
    class SlackAppClient
      SLACK_API_ORIGIN = 'https://slack.com'

      def initialize(options = {})
        @app_token = options[:token]
      end

      def request(path, params = {})
        res = create_http_client.post(
          "/api/#{path}", params.to_json,
          'Content-Type': 'application/json',
          Authorization: "Bearer #{@app_token}"
        )
        parse_response(res.body)
      end

      private

      def create_http_client
        uri = URI.parse(SLACK_API_ORIGIN)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http
      end

      def parse_response(response_body)
        JSON.parse(response_body, object_class: OpenStruct)
      end
    end
  end
end
