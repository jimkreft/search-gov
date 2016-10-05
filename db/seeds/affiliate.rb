Affiliate.create(name: 'usagov', display_name: 'USA.gov')
Affiliate.create(name: 'gobiernousa', display_name: 'GobiernoUSA.gov', locale: 'es')
Affiliate.create(name: 'legacy', display_name: 'Legacy Affiliate', force_mobile_format: false)
Affiliate.create(name: 'sc_enabled', display_name: 'Search Consumer', search_consumer_search_enabled: true)
Affiliate.create!(name: 'i14y_enabled', display_name: 'I14y Affiliate', gets_i14y_results: true) do |affiliate|
  affiliate.i14y_drawers.new(handle: 'my_drawer', description: 'my i14y documents')
end
