winston = require 'winston'

module.exports =
	system:
		loggerConfig:
			transports: [
				new winston.transports.Console
					colorize: 'all'
					level: 'debug'
			]
