class Sites::QueryDownloadsController < Sites::SetupSiteController
  include CSVResponsive
  MAX_RESULTS = 1000000

  def show
    @end_date = request["end_date"].to_date
    @start_date = request["start_date"].to_date
    filename = [@site.name, @start_date, @end_date].join('_')
    header = ['Query Term', 'Total Count (Bots + Humans)', 'Real Count (Humans only)']
    csv_response(filename, header, top_queries)
  end

  private

  def top_queries
    date_range_top_n_query = DateRangeTopNQuery.new(@site.name, @start_date, @end_date, { field: 'raw', size: MAX_RESULTS })
    rtu_top_queries = RtuTopQueries.new(date_range_top_n_query.body, false)
    query_raw_cnt_arr = rtu_top_queries.top_n
    rtu_top_human_queries = RtuTopQueries.new(date_range_top_n_query.body, true)
    query_human_cnt_hash = Hash[rtu_top_human_queries.top_n]
    query_raw_human_arr = query_raw_cnt_arr.map do |query_term, raw_count|
      human_count = query_human_cnt_hash[query_term] || 0
      [query_term, raw_count, human_count]
    end
    query_raw_human_arr.sort_by { |a| -a.last }
  end

end
