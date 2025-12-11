class ApiRequest < ApplicationRecord
  validates :url, presence: true, uniqueness: true
  
  has_many :search_results, dependent: :destroy
  
  CACHE_EXPIRY = 24.hours
  
  def self.cache(url)
    request = find_or_initialize_by(url: url)
    
    if request.persisted? && request.updated_at > CACHE_EXPIRY.ago
      Rails.logger.info "Using cached API request for: #{url}"
      return :cached
    end
    
    Rails.logger.info "Making new API request for: #{url}"
    result = yield
    
    if request.persisted?
      request.touch
    else
      request.save!
    end
    
    result
  end
end

