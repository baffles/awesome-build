# Handles loading the config YAML file.

fs = require 'fs'
yaml = require 'js-yaml'

env = require './env'

module.exports = yaml.safeLoad fs.readFileSync "#{env.root}/#{env.config}", 'utf8'
