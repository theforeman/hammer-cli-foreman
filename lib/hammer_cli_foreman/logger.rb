module HammerCLIForeman
  Logging::LogEvent.add_data_filter(/(token_value(\e\[0;\d{2}m|\e\[0m|\s|=>|")+\")[^\"]*\"/, '\1***"')
end