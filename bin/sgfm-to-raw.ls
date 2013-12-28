
json_filename = \土壤及地下水污染管制區公告資料.json
cache_dir = \cache
raw_dir = \raw

fs = require \fs
landno = require \./lib/landno
{ map, filter, join, keys, split, unique } = require \prelude-ls

section = fs.readFileSync \raw/section.json |> JSON.parse
area-pattern = (city) ->
  section.area
  |> keys
  |> filter (a) -> (a.search city) > -1
  |> map (a) -> a.replace city, ''
  |> join '|'
  |> (s) -> '(' + s + ')'
section-pattern = (city, area) ->
  section.section[section.area.[city + area]]
  |> keys
  |> join '|'
  |> (s) -> '(' + s + ')'
parse-landno = (city, text) ->
  landno = []
  (p = (area-pattern city) + '([^\\d]+(?:、|\\d|\\-)+)') #|> console.log
  pattern = new RegExp p, \g
  while ((result = pattern.exec text) != null)
    result[0] #|> console.log
    (area = result[1]) #|> console.log
    (p2 = (section-pattern city, area) + '((?:、|\\d|\\-)*)') #|> console.log
    pattern2 = new RegExp p2, \g
    while ((result2 = pattern2.exec result[2]) != null)
      result2[0] #|> console.log
      (sec = result2[1]) #|> console.log
      landno ++= map ((n) -> join \|, [city, area, sec, n]), (split '、' result2[2])
  landno = unique landno
  map ((n) -> split \|, n), landno

data = fs.readFileSync \cache/ + json_filename
  |> JSON.parse
  |> (map (d) -> d.LandNo = parse-landno d.County, d.AnnoTitle + d.AnnoContent; d)

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
      (err, d) <- landno.geoJSON (join '', data[anno-i].LandNo[landno-i])
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
