class XlsLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end

logfile = File.open(Rails.root.join('log','xls.log'), 'a')
logfile.sync = true
XLS_LOGGER = XlsLogger.new(logfile)
