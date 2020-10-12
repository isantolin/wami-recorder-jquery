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
package edu.mit.csail.wami.record
{
	import edu.mit.csail.wami.utils.Pipe;
	
	import flash.utils.ByteArray;

	/**
	 * Data can be written to this pipe in any increment, but only chunks of a
	 * fixed size will be passed on to the sink.
	 */
	public class ChunkPipe extends Pipe
	{
		private var chunkSize:int;
		private var closing:Boolean;
		private var buffer:ByteArray;
		
		public function ChunkPipe(size:int) {
			this.chunkSize = size;
			buffer = new ByteArray();
		}
		
		override public function write(data:ByteArray):void 
		{
			while (true)
			{
				var available:int = data.bytesAvailable + buffer.bytesAvailable;
				if (available < chunkSize && !closing) break;  
				// if we get here, there's enough data for another chunk
				
				var chunk:ByteArray = new ByteArray();

				// Add as much as we can from the buffer to this chunk
				var bufferAvailable:int = Math.min(buffer.bytesAvailable, chunkSize);
				buffer.readBytes(chunk, chunk.length, bufferAvailable);
				
				// Add as much as we can from the data passed in to this chunk
				var chunkRemainder:int = Math.max(chunkSize - bufferAvailable, 0);
				var dataAvailable:int = Math.min(data.bytesAvailable, chunkRemainder);
				data.readBytes(chunk, chunk.length, dataAvailable);

				// Write the chunk out
				chunk.position = 0;
				if (chunk.length > 0) super.write(chunk);
				if (closing) break;
			}
			
			updateBuffer(data);
		}

		private function updateBuffer(data:ByteArray):void
		{
			if (buffer.bytesAvailable == 0) 
			{
				// The buffer hits 0 bytes available whenever
				// there was enough data to create a chunk...
				// still should clear out the junk we've written.
				buffer.clear();	
			}
			
			data.readBytes(buffer, buffer.length, data.bytesAvailable);
			buffer.position = 0;
		}
		
		override public function close():void
		{
			closing = true;
			write(new ByteArray());
			super.close();
		}
	}
}
