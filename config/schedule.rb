every 1.minute do
  runner 'BookkeeperMailer.send_report_to_bookkeeper.deliver_now'
end

# send email every 25th (now 4th) of month
#every '55 22 4 * *' do
#   runner 'BookkeeperMailer.send_report_to_bookkeeper.deliver_now'
# end
