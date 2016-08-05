class Report < ActiveRecord::Base

  belongs_to :user

  scope :this_months_report, -> do
    where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
  end

  # def self.this_months_report
  #   where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
  # end
  #validates :body, length: { minimum: 20}
  #csv
  def self.to_csv(user_id=nil)
  	reports = user_id.nil? ? this_months_report : where(user_id: user_id).this_months_report
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

  def self.test
    p 'test passed, dude'
  end

end
