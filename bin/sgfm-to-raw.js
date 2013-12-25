// Generated by LiveScript 1.2.0
var json_filename, cache_dir, raw_dir, posland_url, fs, request, ref$, map, filter, join, keys, split, unique, section, areaPattern, sectionPattern, parseLandno, data;
json_filename = '土壤及地下水污染管制區公告資料.json';
cache_dir = 'cache';
raw_dir = 'raw';
posland_url = 'http://jimmyhub.net:9192/?address=';
fs = require('fs');
request = require('request');
ref$ = require('prelude-ls'), map = ref$.map, filter = ref$.filter, join = ref$.join, keys = ref$.keys, split = ref$.split, unique = ref$.unique;
section = JSON.parse(
fs.readFileSync('raw/section.json'));
areaPattern = function(city){
  return function(s){
    return '(' + s + ')';
  }(
  join('|')(
  map(function(a){
    return a.replace(city, '');
  })(
  filter(function(a){
    return a.search(city) > -1;
  })(
  keys(
  section.area)))));
};
sectionPattern = function(city, area){
  return function(s){
    return '(' + s + ')';
  }(
  join('|')(
  keys(
  section.section[section.area[city + area]])));
};
parseLandno = function(city, text){
  var landno, p, pattern, result, area, p2, pattern2, result2, sec;
  landno = [];
  p = areaPattern(city) + '([^\\d]+(?:、|\\d|\\-)+)';
  pattern = new RegExp(p, 'g');
  while ((result = pattern.exec(text)) !== null) {
    result[0];
    area = result[1];
    p2 = sectionPattern(city, area) + '((?:、|\\d|\\-)*)';
    pattern2 = new RegExp(p2, 'g');
    while ((result2 = pattern2.exec(result[2])) !== null) {
      result2[0];
      sec = result2[1];
      landno = landno.concat(map(fn$, split('、', result2[2])));
    }
  }
  return unique(landno);
  function fn$(n){
    return city + area + sec + n + '地號';
  }
};
data = map(function(d){
  d.LandNo = parseLandno(d.County, d.AnnoTitle + d.AnnoContent);
  return d;
})(
JSON.parse(
fs.readFileSync('cache/' + json_filename)));
fs.writeFileSync('raw/' + json_filename, JSON.stringify(
data));