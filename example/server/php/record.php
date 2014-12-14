<?php

// get the filename
parse_str($_SERVER['QUERY_STRING'], $params);
$file = isset($params['filename']) ? $params['filename'] : 'temp.wav';
// save the recorded audio to that file
$content = file_get_contents('php://input');
$fh = fopen($file, 'w');
$filename = pathinfo($file);

if ($fh != FALSE) {
    fwrite($fh, $content);
    fclose($fh);

    $commandOutput = shell_exec('ffmpeg -i ' . $file . ' -acodec libmp3lame ' . $filename['filename'] . '.mp3');
    $commandOutput .= shell_exec('ffmpeg -i ' . $file . '  -acodec libvorbis ' . $filename['filename'] . '.ogg');

    file_put_contents('log.txt', $commandOutput);
} else {
    echo "can't open file";
}
