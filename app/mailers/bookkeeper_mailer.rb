class BookkeeperMailer < ActionMailer::Base
  # require 'mail'
  default from: 'testcybermail@yandex.ru'
  layout 'send_report_to_bookkeeper'
  
   def send_report_to_bookkeeper
     p ActionMailer::Base.deliveries.count
     # @bookkeeper = Mail::Address.new 'm.potashnykova@gmail.com'
     bookkeeper = 'm.potashnykova@gmail.com'
     # @bookkeeper = bookkeeper
    #reports_csv = Report.download_reports
    #attachments[reports_csv] = month_report
  	
  	mail(to: bookkeeper, subject: 'Cybercraft month report')
   #   do |format|
  	# 	format.html { render layout: 'send_report_to_bookkeeper' }
  	# 	format.text
  	# end
  	
  	#p 'executed'
    #p ActionMailer::Base.deliveries.count
  end
  
end
