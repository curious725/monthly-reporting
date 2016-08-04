
require 'clockwork'
require_relative '../../config/boot'
require_relative '../../config/environment'

module Clockwork
  # handler do |job|
  #   case job
  #     when 'Run bg job'
  #       Report.test
  #   end
  # end

  # every(10.seconds, 'Run bg job')

  handler do |job|
  	case job
  	  when 'Send month report'
  	  	BookkeeperMailer.send_report_to_bookkeeper.deliver
  	  end
  end

  #every(end_of_month, 'Send month report')
  every(30.seconds, 'Send month report')

end
