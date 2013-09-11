assert = require("assert-plus")
bunyan = require("bunyan")
express = require("express")
api = require('./api')
  
createLogger = () ->

  # In true UNIX fashion, debug messages go to stderr, and audit records go
  # to stdout, so you can split them as you like in the shell
  default_stream = 
    level: (process.env.LOG_LEVEL || 'info'),
    stream: process.stderr
    
  debug_stream =
    # This ensures that if we get a WARN or above all debug records
    # related to that request are spewed to stderr - makes it nice
    # filter out debug messages in prod, but still dump on user
    # errors so you can debug problems
    level: 'debug',
    stream: process.stderr
            
  bunyan.createLogger
    name: "democracy-server",
    streams: [default_stream, debug_stream]

  
app = express()
logger = createLogger()

app.configure ->
  app.use express.logger("dev") # 'default', 'short', 'tiny', 'dev'
  app.use(express.compress());
  app.use(express.methodOverride());
  app.use(express.bodyParser());
  app.use((req, res, next) ->
    req.log = logger
    next()
  )
  api.createAPI(app)

  # Register a default '/' handler
  app.get "/", (req, res, next) ->
    res.send 200, app.routes
  
module.exports = app