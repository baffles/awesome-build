# Provides a winston logger instance

config = require 'config'
winston = require 'winston'

module.exports = new winston.Logger config.get 'system.loggerConfig'
