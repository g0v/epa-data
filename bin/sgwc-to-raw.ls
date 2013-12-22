
json_filename = \土壤及地下水污染場址基本資料.json
cache_dir = \cache
raw_dir = \raw

fs = require \fs
proj = require \proj4
{ map } = require \prelude-ls

TWD97TM2 = proj.defs["EPSG:3826"] = "+title=TWD97 TM2+proj=tmerc +lat_0=0 +lon_0=121 +k=0.9999 +x_0=250000 +y_0=0 +ellps=GRS80 +units=公尺 +no_defs"

transform = (point) -> proj(TWD97TM2, \EPSG:4326, point)

fs.readFileSync cache_dir + '/' + json_filename
  |> JSON.parse
  |> (map (d) -> {
    type: \Feature
    properties: d
    geometry: {
      type: \Point
      coordinates: transform [d.TWD97TM2X, d.TWD97TM2Y]
    }
  })
  |> JSON.stringify
  |> fs.writeFileSync raw_dir + '/' + json_filename, _
