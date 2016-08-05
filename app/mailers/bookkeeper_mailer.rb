class BookkeeperMailer < ActionMailer::Base
  # require 'mail'
  default from: 'cool.martin-borman@yandex.ru'
  layout 'send_report_to_bookkeeper'
  
   def send_report_to_bookkeeper
     p ActionMailer::Base.deliveries.count
     # @bookkeeper = Mail::Address.new 'm.potashnykova@gmail.com'
     bookkeeper = 'm.potashnykova@gmail.com'
     
      attachments['monthly_report.csv'] = { mime_type: 'text/csv', content: Report.to_csv.reverse }
      mail(to: bookkeeper, subject: 'Cybercraft month report'.reverse)
          # raise attachments.inspect

        # format.html { render layout: 'send_report_to_bookkeeper' }
        # format.text
    
     # mail(:to => user.email, :subject => "awesome pdf, check it") do |format|
      # format.text # renders send_report.text.erb for body of email
     #  format.pdf do
     #    attachments['MyPDF.pdf'] = WickedPdf.new.pdf_from_string(
     #      render_to_string(:pdf => 'MyPDF',:template => 'reports/show.pdf.erb')
     #    )
      # end
    end
end

  	 # mail(to: bookkeeper, subject: 'Cybercraft month report') do |format|
    #   format.csv do
    #     attachments['monthly_report.csv'] = { mime_type: 'text/csv', content: Report.to_csv }
    #   end

  	# 	format.html { render layout: 'send_report_to_bookkeeper' }
  	# 	format.text
  	# end
  	
  	#p 'executed'
    #p ActionMailer::Base.deliveries.count
#   end
  
# end
