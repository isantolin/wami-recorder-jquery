/**
 * Lib to help the recording of user's microphone
 *
 * @param string script_base Base URL to this directory
 * @param string url URL used to send the audio data to the server
 * @param HTMLElement el HTML element where the SWF of Wami will be placed
 * @param string [save_url] Saving URL (if it differs from the URL where the audio data is sent)
 * @param function [onReadyCb] Callback function fired when SWF is ready
 * @uses Wami http://code.google.com/p/wami-recorder/
 */
function AudioRecorder(script_base, url, el, save_url, onReadyCb) {
	this.url = url+"?";
	if (save_url === undefined) {
		save_url = url;
	}
	this.save_url = save_url;

	// removes the flash container, if exists
	$(el).find('#flash').remove();
	// adds the flash container
	$(el).append('<div id="flash"></div>');

	$.ajax({
		url: script_base + '/recorder.js',
		dataType: 'script',
		cache: true
	}).done(function() {
		Wami.setup({id: 'flash', swfUrl: script_base + "/../Wami.swf", onReady: onReadyCb });
	});
}

/**
 * Start to capture de audio.
 */
AudioRecorder.prototype.start = function(startfn, finishedfn, failedfn) {
	Wami.startRecording(
		this.url,
		Wami.nameCallback(startfn),
		Wami.nameCallback(finishedfn),
		Wami.nameCallback(failedfn)
	);
};
/**
 * Stop the capture of the audio.
 */
AudioRecorder.prototype.stop = function() {
	Wami.stopRecording();
	Wami.stopPlaying();
};
/**
 * Play the audio sent to the server. Server must serve the Wav file
 */
AudioRecorder.prototype.play = function(startfn, finishedfn, failedfn) {
	Wami.startPlaying(
		this.url,
		Wami.nameCallback(startfn),
		Wami.nameCallback(finishedfn),
		Wami.nameCallback(failedfn)
	);
};
/**
 * Stop the audio preview
 */
AudioRecorder.prototype.pause = function() {
	Wami.stopPlaying();
};
/**
 * saves the audio in the server
 */
AudioRecorder.prototype.save = function(fn) {
	$.ajax({
		url: this.save_url,
		complete: function(result) {
			fn && fn(result);
		}
	});
};
