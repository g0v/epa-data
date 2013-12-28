
api_url = \http://jimmyhub.net:9192/?address=

request = require \request

cache = {}

module.exports.geoJSON = (addr, cb) ->
  return unless cb
  if cache[addr]
    return cb null, cache[addr]
  (err, response, body) <- request api_url + addr
  if err
    return cb err
  data = JSON.parse body
  if data.length < 2
    return cb err
  cache[addr] = [ data.1.cx, data.1.cy ]
  cb null, cache[addr]
