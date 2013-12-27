
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

data |> JSON.stringify |> fs.writeFileSync \raw/ + json_filename, _
