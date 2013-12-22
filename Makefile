# 
# GISCaseDistribution_URL=http://opendata.epa.gov.tw/Data/DownloadFile/GISCaseDistribution/?file=http%3a%2f%2fgis.epa.gov.tw%2fDownload.aspx%3fLayerID%3d10800100%26LdTypeID%3d2
# 
# 	ogr2ogr -f GeoJSON -t_srs EPSG:3826 公害陳情案件分佈圖.json 公害陳情案件分佈圖.shp
# 	piconv -f big5 -t utf8 公害陳情案件分佈圖.json tmp.json
# 	mv tmp.json 公害陳情案件分佈圖.json


cache/焚化廠空污檢測資料.json:
	curl -o cache/焚化廠空污檢測資料.json 'http://opendata.epa.gov.tw/ws/Data/SWIMSAir/?$orderby=ReportDate%20desc&$skip=0&$top=1000&format=json'

cache/焚化廠基本資料.json:
	curl -o cache/焚化廠基本資料.json 'http://opendata.epa.gov.tw/ws/Data/SWIMS/?$orderby=IncineratorName%20desc&$skip=0&$top=1000&format=json'
