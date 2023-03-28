every 5.minutes do
  runner "ImportColorado.perform_later"
  runner "ImportRasterlinkV2.perform_later"
  runner "ImportRasterlink.perform_later"
  runner "ImportSwissQ.perform_later"
  runner "ImportZund.perform_later"
end

every 15.minutes do
  runner "Ping.perform_later"
  runner "MountMachines.perform_later"
end

every 1.day, at: ['2:00 am', '1:00 pm'] do
  runner "Backup.perform_later"
end

every 1.day, at: ['3:00 am'] do
  runner "ActiveStorageCleanUp.perform_later"
  # Controllo anche che tutte le stampanti abbiano importato i dati
end
