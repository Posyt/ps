# Reference -- https://github.com/elasticsearch/elasticsearch-rails/blob/master/elasticsearch-rails/lib/rails/templates/searchable.rb
# Marvel - Sense -
## Install - https://gist.github.com/alabid/efe2ee41c6308e88103c
## -- http://www.elasticsearch.org/overview/marvel/download/
## Marvel uri - http://localhost:9200/_plugin/marvel/
module SearchableArticle
	extend ActiveSupport::Concern

	included do
		include Elasticsearch::Model

		# TODO: Pick the lang dynamically based on the lang of the current note. Be sure to generate a separate mapping with analyzers for each lang.
		# index_name "#{Rails.application.class.parent_name.downcase}_#{Rails.env}_articles-en"
		index_name "articles"

		after_save lambda { Indexer.perform_async(:index,  self.class.to_s, self._id.to_s) }
		after_destroy lambda { Indexer.perform_async(:delete, self.class.to_s, self._id.to_s) }

    settings index: {
			:number_of_shards => (1).to_i,
			:number_of_replicas => (1).to_i,
			:analysis => {
				:filter => {
					:autocomplete_ngram  => {
						"type"     => "ngram",
						"min_gram" => 2,
						"max_gram" => 16 }
				},
				:analyzer => {
					:ps_autocomplete => {
						"type"         => "custom",
						"tokenizer"    => "standard",
						"filter"       => [ "standard", "lowercase", "stop", "kstem", "autocomplete_ngram" ]
					},
					ps_english: {
						type: "english",
						# stem_exclusion: [ "organization", "organizations" ],
						stopwords: [
							"a", "an", "and", "are", "as", "at", "be", "but", "by", "for",
							"if", "in", "into", "is", "it", "of", "on", "or", "such", "that",
							"the", "their", "then", "there", "these", "they", "this", "to",
							"was", "will", "with"
						]
					}
				}
			}
		} do
			mappings dynamic: false do
				indexes :_id, type: 'string', index: :not_analyzed, store: true # _id is an elasticsearch system value so use id
        indexes :source, type: 'string', analyzer: 'keyword'
				indexes :url, type: 'string', index: :not_analyzed
				indexes :title, type: 'string', analyzer: 'ps_english', fields: {
					standard: { type: 'string', analyzer: 'standard' },
					autocomplete: { type: 'string', analyzer: 'ps_autocomplete', search_analyzer: 'snowball' }
				}, :boost => 2.0 # TODO: I18N: don't just assume english
				indexes :categories, type: 'string', analyzer: 'keyword', :boost => 3.0
				indexes :author, type: 'string', analyzer: 'keyword', :boost => 2.0
        indexes :description, type: 'string', analyzer: 'ps_english', fields: {
					standard: { type: 'string', analyzer: 'standard' },
					autocomplete: { type: 'string', analyzer: 'ps_autocomplete', search_analyzer: 'snowball' }
				}, :boost => 1.5 # TODO: I18N: don't just assume english
				indexes :points, type: 'integer'
				indexes :comments, type: 'integer'
				indexes :normalized_popularity, type: 'integer'
				indexes :created_at, type: 'date'
				indexes :updated_at, type: 'date'
				indexes :published_at, type: 'date'

				indexes :sources, type: 'nested' do
          indexes :name, type: 'string', analyzer: 'keyword'
  				indexes :url, type: 'string', index: :not_analyzed
  				indexes :title, type: 'string', analyzer: 'ps_english', fields: {
  					standard: { type: 'string', analyzer: 'standard' },
  					autocomplete: { type: 'string', analyzer: 'ps_autocomplete', search_analyzer: 'snowball' }
  				}, :boost => 2.0 # TODO: I18N: don't just assume english
  				indexes :categories, type: 'string', analyzer: 'keyword', :boost => 3.0
  				indexes :author, type: 'string', analyzer: 'keyword', :boost => 2.0
          indexes :description, type: 'string', analyzer: 'ps_english', fields: {
  					standard: { type: 'string', analyzer: 'standard' },
  					autocomplete: { type: 'string', analyzer: 'ps_autocomplete', search_analyzer: 'snowball' }
  				}, :boost => 1.5 # TODO: I18N: don't just assume english
  				indexes :points, type: 'integer'
  				indexes :comments, type: 'integer'
  				indexes :normalized_popularity, type: 'integer'
  				indexes :created_at, type: 'date'
  				indexes :updated_at, type: 'date'
  				indexes :published_at, type: 'date'
				end
			end
		end

		def as_indexed_json(options={})
			ret = {
        source: self.source,
				_id: self._id.to_s,
        url: self.url,
				title: self.title,
				author: self.author,
        categories: self.categories,
				description: self.description,
				points: self.points,
				comments: self.comments,
				normalized_popularity: self.normalized_popularity,
				published_at: self.published_at,
				created_at: self.created_at,
				updated_at: self.updated_at,
			}
      ret[:sources] = self.sources.as_json({ only: [:name, :url, :title, :author, :categories, :description, :points, :comments, :normalized_popularity, :published_at, :created_at, :updated_at] }) if self.sources.any?
			ret
		end

	end
end
