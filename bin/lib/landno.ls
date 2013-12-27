
api_url = \http://jimmyhub.net:9192/?address=

request = require \request

module.exports.getGeoJSON = (addr, cb) ->
  return unless cb
  (err, response, body) <- request api_url + addr
  if (err)
    return cb err
  data = JSON.parse body
  cb null, {
    type: \Point
    coordinates: [ data.1.cx, data.1.cy ]
  }
