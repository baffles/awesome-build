# Provides a winston logger instance

env = require './env'
winston = require 'winston'

module.exports = new winston.Logger env.loggerConfig ? { transports: [ new winston.transports.Console ] }
