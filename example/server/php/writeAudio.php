<?php

// grava_audio.php
session_start();
$session_id = session_id();
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    parse_str($_SERVER['QUERY_STRING'], $params);
    $name = "{$session_id}.wav";
    $content = file_get_contents('php://input');
    $fh = fopen($name, 'w') or die("can't open file");
    fwrite($fh, $content);
    fclose($fh);
} else {
    if (isset($_GET['save'])) {// converts to mp3 using lame
        $commandOutput = shell_exec("ffmpeg -i {$session_id}.wav -acodec libmp3lame {$session_id}.mp3");
        $commandOutput .= shell_exec("ffmpeg -i {$session_id}.wav  -acodec libvorbis {$session_id}.ogg");
        file_put_contents('log.txt', $commandOutput);
    } elseif (file_exists("{$session_id}.wav")) {
        readfile("{$session_id}.wav");
    }
}
?>