# TODO: calculate concurrency - http://manuel.manuelles.nl/blog/2012/11/13/sidekiq-on-heroku-with-redistogo-nano/
if defined?(Sidekiq)
	Sidekiq.configure_server do |config|
		# TODO: increase when you have more redis memory to spare
		# Keep it low to keep the memory footprint low
		config.failures_max_count = 20
		config.failures_default_mode = :all
	end
end
