class MachineLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n"
  end
end

logfile = File.open(Rails.root.join('log','machine.log'), 'a')
logfile.sync = true
MACHINE_LOGGER = MachineLogger.new(logfile)
