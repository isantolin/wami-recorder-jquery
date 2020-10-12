/* 
* Copyright (c) 2011
* Spoken Language Systems Group
* MIT Computer Science and Artificial Intelligence Laboratory
* Massachusetts Institute of Technology
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
* BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/ 
package edu.mit.csail.wami.client
{
	import edu.mit.csail.wami.utils.External;
	import edu.mit.csail.wami.utils.StateListener;
	
	import flash.display.*;
	import flash.media.*;
	import flash.system.*;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * Flash settings.  This class is largely to get around a shortcoming in
	 * Flash.  Although, you can listen for changes to the microphone status,
	 * there appears to be no good way to listen for a status event to tell you
	 * when the settings dialogue has been closed.  This hack should suffice.
	 */
	public class FlashSettings extends flash.display.MovieClip
	{
		private static var MAX_CHECKS:uint = 5;
		
		private var theStage:Stage;

		private var checkSettingsIntervalID:int = 0;

		private var showedPanel:Boolean = false;
		private var checkAttempts:int = 0;
		private var listener:StateListener;

		public function FlashSettings(s:Stage)
		{
			super();
			theStage = s;
			External.addCallback("showSecurity", showSecurity);
		}

		// Possible values that settings parameter can take are those of the 
		// string constants documented by Adobe in flash.system.SecurityPanel.
		public function settingsPanel(settings:String, listener:StateListener):void
		{
			this.showedPanel = false;
			this.checkAttempts = 0;
			this.listener = listener;
			
			flash.system.Security.showSettings(settings);
			checkSettings();
		}
		
		private function checkSettings():void
		{
			clearInterval(checkSettingsIntervalID);
			
			var closed:Boolean = false;
			if (showingPanel())
			{
				if (!showedPanel) 
				{
					if (listener) {
						listener.started();
					}
				}
				showedPanel = true;
			}
			else if (showedPanel)
			{
				closed = true;
			}
			
			if (closed)
			{
				if (listener) {
					listener.finished();
				}
				return;
			}
			
			External.debug("check attempts: " + checkAttempts);
			checkAttempts++;
			if (checkAttempts > MAX_CHECKS && showedPanel != true)
			{
				External.debug("failed");
				if (listener) 
				{
					listener.failed(new Error("Security panel never showed up.  Perhaps the browser is zoomed out too far.  Try to zoom in and refresh."));
				}
				return;
			}

			checkSettingsIntervalID = setInterval(checkSettings, 250);
		}
		
		private function showingPanel():Boolean
		{
			var showing:Boolean = false;
			var dummy:BitmapData;
			dummy = new BitmapData(1,1);
			
			try
			{
				// Try to capture the stage: triggers a Security error when the settings dialog box is open 
				// Unfortunately, this is how we have to poll the settings dialogue to know when it closes
				dummy.draw(theStage);
			}
			catch (error:Error)
			{
				External.debug("Still not closed, could not capture the stage: " + theStage);
				showing = true;
			}
			
			dummy.dispose();
			dummy = null;
			
			return showing;
		}


		internal function showSecurity(panel:String,
									   startedCallback:String = null, 
									   finishedCallback:String = null,
									   failedCallback:String = null):void
		{
			settingsPanel(panel, new WamiListener(startedCallback, finishedCallback, failedCallback));
		}
	}
}
