class ElasticBlendedQuery < ElasticTextFilteredQuery
  FRAGMENT_SIZE = 75

  def initialize(options)
    super(options)
    @affiliate_id = options[:affiliate_id]
    @rss_feed_url_ids = options[:rss_feed_url_ids]
    self.highlighted_fields = %w(title description body)
  end

  def body
    Jbuilder.encode do |json|
      indices_boost(json)
      query(json)
      highlight(json) if @highlighting
    end
  end

  def query(json)
    json.query do
      json.function_score do
        super(json)
        json.functions do
          json.child! do
            json.boost_factor 10.0
            json.filter do
              json.range do
                json.published_at do
                  json.gt 1.week.ago.beginning_of_day
                end
              end
            end
          end
        end
      end
    end
  end

  def indices_boost(json)
    #FIXME: use aliases when https://github.com/elasticsearch/elasticsearch/issues/4756 is fixed
    index_names = ES::client_reader.indices.get_alias(name: ElasticBlended.reader_alias.join(',')).keys.sort
    json.indices_boost do
      index_names.each_with_index do |index_name, idx|
        json.set! index_name, ElasticBlended::INDEX_BOOSTS[idx]
      end
    end
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        json.set! :should do |json|
          json.child! { json.term { json.affiliate_id @affiliate_id } }
          json.child! { json.terms { json.rss_feed_url_id @rss_feed_url_ids } }
        end
      end
    end
  end

  def highlight_fields(json)
    json.fields do
      json.set! :title, { number_of_fragments: 0 }
      json.set! :description, { fragment_size: FRAGMENT_SIZE, number_of_fragments: 2 }
      json.set! :body, { fragment_size: FRAGMENT_SIZE, number_of_fragments: 2 }
    end
  end

  def pre_tags
    %w()
  end

  def post_tags
    %w()
  end

end