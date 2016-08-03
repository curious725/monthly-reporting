class Report < ActiveRecord::Base

  belongs_to :user
  
  #validates :body, length: { minimum: 20}
  #csv
  def self.to_csv(user_id=nil)
  	reports = user_id.nil? ? all : where(user_id: user_id)
  	reports = reports.to_a
  	#reports = where(user_id: user_id).to_a
  	CSV.generate do |csv|
  		# raise column_names.inspect
  		csv << column_names
  		reports.each do |report|
  		  csv << report.attributes.values_at(*column_names)
  		end
  	end
  end
end
