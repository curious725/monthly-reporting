class BookkeeperMailer < ActionMailer::Base

  def send_report_to_bookkeeper(bookkeeper, month_report)
  	bookkeeper = m.potashnykova@gmail.com
  	reports_csv = Report.download_reports
  	attachments[reports_csv] = month_report
  	
  	mail(to: bookkeeper, subject: 'Cybercraft month report') do |format|
  		format.html { render layout: 'send_report_to_bookkeeper' }
  		format.text
  	end
  	
  	
  end
  
end