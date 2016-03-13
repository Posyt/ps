module Neo
	class << self
		def neo
			if @neo.nil?
				Neography.configure do |config|
					config.protocol           = ENV["NEO_PROTOCOL"] || "http://"
					config.server             = ENV["NEO_SERVER"] || "localhost"
					config.port               = ENV["NEO_PORT"] || 7474
					config.directory          = ""  # prefix this path with '/'
					config.log_file           = "neography.log"
					config.log_enabled        = false
					config.slow_log_threshold = 0    # time in ms for query logging
					config.max_threads        = 20
					config.authentication     = ENV["NEO_AUTH"] || 'basic'  # 'basic' or 'digest'
					config.username           = ENV["NEO_USERNAME"] || 'neo4j'
					config.password           = ENV["NEO_PASSWORD"] || 'password'
					config.parser             = MultiJsonParser
				end

				@neo = Neography::Rest.new
			else
				@neo
			end
		end

		def execute(query, parameters = {}, cypher_options = nil)
			tries = 0

			while tries < 3
				begin
					data = Neo.neo.execute_query(query, parameters, cypher_options)
					break
				rescue Neography::NeographyError => e
					return e.message
				rescue Errno::ECONNREFUSED
					tries += 1
					sleep(2)
					if tries == 3
						break
						# queue to redis for writing when database is back
					end
				end
			end

			return data
		end
	end
end
