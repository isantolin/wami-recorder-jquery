Wami Recorder for Jquery 1.1.3 by Ignacio Santolin
================================================

About The Authors
-----------------
* Original Code Taken from https://code.google.com/p/wami-recorder/ (Under MIT License)

* Code Updates, Tweaks for JQuery and Some fixes By Ignacio Santolin
	- Mail: ignacio.santolin[at]gmail.com
	- Github: https://github.com/isantolin


The Problem
-----------
As of this writing, most browsers still do not support WebRTC's getUserMedia()

http://caniuse.com/#search=stream

which promises to give web developers microphone access via Javascript. This project achieves the next best thing for browsers that support Flash. Using the WAMI recorder, you can collect audio on your server without installing any proprietary media server software.

The Solution
------------
The WAMI recorder uses a light-weight Flash app to ship audio from client to server via a standard HTTP POST. Apart from the security settings to allow microphone access, the entire interface can be constructed in HTML and JQuery.


The Client
----------
The Flash app exposes most of its important parameters and functionality to the Javascript.

```
Wami.startRecording(myRecordURL);
Wami.stopRecording();

Wami.startPlaying(anyWavURL);
Wami.stopPlaying();
```

You can use the well-respected SWFObject library to embed the Flash app, and then access it in the same way as our example code. Take a look at our quirks page to get acquainted with the idiosyncrasies of Flash and Javascript on different browsers and operating systems.

If you want to modify the Flash content you can download the free Flex SDK, and compile it from the command line. For a full-fledged IDE, your free options are more limited. For academic use, such as collecting audio for a study via Amazon Mechanical Turk, you can register for a free educational Adobe Flash Builder license.


The Server
----------
If you want to collect audio from the browser, there is no getting around the need to host your own server. However, a key feature of this project is that there is no need to configure an entire Flash Media Server just to collect audio from the web. You can choose whatever server-side technology you prefer. You could, for instance, host this simple PHP script on Apache2:

```
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

?>
```

Notice that this code optionally takes a URL query parameter to specify a file name. With the appropriate permissions, the PHP code will write a file with this nam to disk. You can pass a different file name every time you record to distinguish between individual users, sessions, and utterances. You might wish to use random numbers generated in Javascript and cookies stored in the browser to track users across browser reloads and to name their corresponding files. It should be noted that the example above suffers from security issues, and should probably be modified for actual deployment.

```
Wami.startRecording('http://localhost/test.php?name=USER.SESSION.UTTERANCE.wav');
```

A slight complication occurs if the URL that you use for playing or recording does not point to the same host that serves the SWF file. In that case, you will need to serve a crossdomain.xml at the root of the host from which the audio is served or recorded.
