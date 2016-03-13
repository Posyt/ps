module GraphableArticle
	extend ActiveSupport::Concern

	included do
		after_save lambda { Article.delay(queue: 'neo4j').graph(self._id.to_s) }
		# after_destroy lambda { Article.ungraph(:delete, self.class.to_s, self._id.to_s) }

		def self.graph(id)
			article = Article.find(id)
			sourceNames = ([article.source] + article.sources.map(&:name)).compact.uniq
			Neo.execute(%{
					MERGE (a:Article { _id: {articleId} })
					SET a.url={articleUrl}, a.createdAt={articleCreatedAt}, a.title={articleTitle}
					WITH a
					FOREACH (name IN {sourceNames} |
						MERGE (s:Source { name: name })
						MERGE (s)-[:sourced]->(a)
					)
				}, {
					articleId: article._id.to_s,
					articleUrl: article.url,
					articleCreatedAt: article.created_at,
					articleTitle: article.title,
					sourceNames: sourceNames
				}
			)
		end

	end
end
