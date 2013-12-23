<?php
// 抓取 http://opendata.epa.gov.tw/Data/Download/WQXRiver/ 的河川水質監測資料
$skip = 0;
$sample_date = null;
$datas = array();

while (true) {
    $url = "http://opendata.epa.gov.tw/ws/Data/WQXRiver/?\$orderby=SampleDate%20desc&\$skip={$skip}&\$top=1000&format=csv";
    error_log($url);
    $curl = curl_init($url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    $ret = curl_exec($curl);

    file_put_contents('temp.csv', $ret);
    if (!$ret) {
        break;
    }

    $fp = fopen('temp.csv', 'r');
    $columns = fgetcsv($fp);
    $empty = true;
    while ($rows = fgetcsv($fp)) {
        $empty = false;
        if (!is_null($sample_date) and $rows[10] != $sample_date) {
            $output = fopen(__DIR__ . '/../raw/河川水質監測資料/' . $sample_date . ".csv", "w");
            fputcsv($output, $columns);
            foreach ($datas as $data) {
                fputcsv($output, $data);
            }
            fclose($output);
            $datas = array();
        }
        $sample_date = $rows[10];
        $datas[] = $rows;
    }

    if ($empty) {
        break;
    }

    $skip += 1000;
}

$output = fopen(__DIR__ . '/../raw/河川水質監測資料/' . $sample_date . ".csv", "w");
fputcsv($output, $columns);
foreach ($datas as $data) {
    fputcsv($output, $data);
}
fclose($output);

if (file_exists('temp.csv')) {
    unlink('temp.csv');
}
