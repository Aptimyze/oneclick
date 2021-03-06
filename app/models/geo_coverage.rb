class GeoCoverage < ActiveRecord::Base

  #associations
  has_many :service_coverage_maps
  has_many :services, through: :service_coverage_maps

  #coverage_type: zipcode, county_name, polygon, city
  # attr_accessible :coverage_type, :value, :polygon

  scope :not_endpoint, -> { where.not(coverage_type: 'endpoint_area') }
  scope :not_coverage, -> { where.not(coverage_type: 'coverage_area') }


  def polygon_contains?(lon, lat)
    factory = RGeo::Geographic.simple_mercator_factory
    point = factory.point(lon.to_f, lat.to_f)

    self.boundary.geom.contains? point

  end

end
