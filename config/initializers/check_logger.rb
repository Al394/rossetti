class CheckLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end

logfile = File.open(Rails.root.join('log','check.log'), 'a')
logfile.sync = true
CHECK_LOGGER = CheckLogger.new(logfile)
