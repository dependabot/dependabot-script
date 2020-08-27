module Status
  FILTERED_OUT = "FILTERED_OUT"
  UP_TO_DATE = "UP_TO_DATE"
  UPDATE_NOT_POSSIBLE = "UPDATE_NOT_POSSIBLE"
  UPDATED = "UPDATED"
end

class MetricsPublisher

  def initialize(endpoint: nil, repository: nil)
    @endpoint = endpoint
    @repository = repository
    @date = Date.today.to_s
    @attempt_id = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
    @messages = ''
  end

  def track(dependency, status, version_checker=nil)
    message = {}
    message[:dependency] = dependency.display_name
    message[:from_version] = dependency.version
    message[:to_version] = version_checker&.latest_version || "" 
    message[:attempt_id] = @attempt_id
    message[:attempt_date] = @date
    message[:status] = status
    message[:repository] = @repository
    @messages << construct_bulk_data(message)
  end

  def construct_bulk_data(data)
    glue = "\n#{{ index: {} }.to_json}\n"
    [glue, data.to_json, glue].join
  end


  def flush()
    els_db = @endpoint
    index = "dependabot"
    index_date = Date.today.to_s
    stats_type = "update_metrics"

    endpoint = "#{els_db}/#{index}/#{stats_type}/_bulk"
    metrics_publisher = MetricsPublisher.new(endpoint: endpoint)
    metrics_publisher.publish(metrics: @messages)
  end

  def construct_bulk_data(data)
    glue = "\n#{{ index: {} }.to_json}\n"
    [glue, data.to_json, glue].join
  end


  def publish(metrics: nil)
    raise 'No metrics to post!!!' if metrics.nil?

    uri = URI(@endpoint)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = metrics

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    unless res.is_a? Net::HTTPSuccess
      puts <<~MESSAGE
        Metrics publish result - Code: #{res.code}, Message: #{res.message}
      MESSAGE
    end
  rescue => ex
    puts <<~MESSAGE
      Publishing metrics: #{metrics} failed with exception: #{ex}
        #{ex.backtrace.pretty_inspect}
    MESSAGE
  end
end