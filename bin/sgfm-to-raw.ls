
json_filename = \土壤及地下水污染管制區公告資料.json
cache_dir = \cache
raw_dir = \raw

fs = require \fs
landno = require \./lib/landno
{ map, filter, join, keys, split, unique } = require \prelude-ls

data = fs.readFileSync \cache/ + json_filename
  |> JSON.parse
  |> (map (d) -> d.LandNo = landno.parse-landno d.County, d.AnnoTitle + d.AnnoContent; d)

anno-i = 0
landno-i = 0

geoJSONize = (data, ending) ->
  anno-i := 0
  landno-i := 0
  process-landno = (ending) ->
    if landno-i == data[anno-i].LandNo.length
      ending!
    else
      \( + anno-i + \, + landno-i + ') ' + (join '', data[anno-i].LandNo[landno-i]) |> console.log
      (err, d) <- landno.coordinates (join '', data[anno-i].LandNo[landno-i])
      unless err or not d
        data[anno-i].points.push d
      ++landno-i
      process-landno ending
  process-anno = (ending) ->
    if anno-i == data.length
      ending {
        type: \FeatureCollection
        features: data |> filter ((d) -> d.geometry.coordinates.length > 0)
      }
    else
      data[anno-i].points = []
      process-landno ->
        if data[anno-i].points.length == 1
          data[anno-i] = {
            type: \Feature
            geometry:
              type: \Point
              coordinates: data[anno-i].points.0
            properties: data[anno-i]
          }
        else
          data[anno-i] = {
            type: \Feature
            geometry:
              type: \MultiPoint
              coordinates: data[anno-i].points
            properties: data[anno-i]
          }
        delete data[anno-i].points
        ++anno-i
        landno-i := 0
        process-anno ending
  data[anno-i].points = []
  process-anno ending

(data) <- geoJSONize filter ((d) -> d.LandNo.length > 0), data
data
  |> JSON.stringify
  |> fs.writeFileSync \raw/ + json_filename, _
