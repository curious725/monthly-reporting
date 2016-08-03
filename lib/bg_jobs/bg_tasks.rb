
require 'clockwork'
require_relative './config/boot'
require_relative './config/environment'

module Clockwork
  handler do |job|
    case job
      when 'Run bg job'
        Report.test
    end
  end

  every(10.seconds, 'Run bg job')
  
end
