package nest.services.worker.test
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import nest.services.worker.WorkerService;
	
	public class LoopWorker extends WorkerService
	{
		public function LoopWorker(loaderBytes:ByteArray = null, privileges:Boolean = false)   {
			super(loaderBytes, privileges);
			trace("worker inited");
		}	
		
		// draw pixels
		final public function drawpixels(numpixels:uint, progressPercent:Number, _w:int, _h:int, onComplete:Function = null, onProgress:Function = null):void {	
//			__mutex.unlock();
			if (callWorker("drawpixels", arguments, onComplete, onProgress)){
				return;
			}
			
			debug("starting processing", numpixels, "of data");
			
			// convert bitmapdata to bytearray
			function bmdToBytearray(bmd:BitmapData,dispose:Boolean=false) : ByteArray {
				var ba:ByteArray = new ByteArray;
				bmd.copyPixelsToByteArray(bmd.rect, ba);
				ba.position = 0;
				if (dispose) bmd.dispose();
				return ba;
			}
			
			var canceled : Boolean = false;
			var canvas : BitmapData = new BitmapData(_w, _h, false,0x000000);
			var startTime : int = getTimer();
			var endTime:int;

			// to handle cancellation and progress reporting 
			// we must execute the process outside the main loop
			// so I use old pseudo threading to trick this situation
			// I split the whole process into several blocks of process
			// and execute them as new thread on timer event 
			
			var step 		: uint = 0;
			var steps		: uint = Math.ceil(numpixels * (progressPercent / 100));
			var stepsX		: uint = Math.floor(_w * (progressPercent / 100));
			var stepsY		: uint = Math.floor(_h * (progressPercent / 100));
			
			var totalChunks	: int = Math.floor(numpixels / steps);
			if (numpixels > totalChunks * steps) totalChunks++;
			
//			var x : int = _w;
//			var y : int = _h;
//			var color : uint;
//			while (x || y) {
//				// the process
//				
//				color = Math.random() * 0xFFFFFF;
//				x--;
//				if(x % stepsX > 0 && y % stepsY > 0) canvas.setPixel(x, y, color);
//				if(x == 0) {
//					y--;
//					if(y > 0) x = _w
//				}
//			}
//			
//			endTime = getTimer() - startTime;
//			onComplete(true, step, bmdToBytearray(canvas,true), endTime);
//			debug("job completed in ", endTime, "ms");
//			
//			canvas.dispose();
			
			
			// creating the batch with 0ms delay and single iteration
			
//			var batch : Thread = new Thread(0, 1);
			
			function onProcessComplete():void {
				if(onProgress) onProgress(step, numpixels,bmdToBytearray(canvas))
				endTime = getTimer() - startTime;
				onComplete(true, step, bmdToBytearray(canvas,true), endTime);
				debug("job completed in ", endTime, "ms");
				canvas.dispose();
			}
			
			function onProcessCancel():void {
//				batch.stop();
				this["debug"].call(this, "job was canceled at #" + step.toString());
				endTime = getTimer() - startTime;
				onComplete(false,step,bmdToBytearray(canvas,true),endTime);
				canvas.dispose();
			}
			
			for (var chunk:int = 0; chunk < totalChunks; chunk++) {
//				batch.add(
//					function() : void {
						// cancelation check
						if (canceled) {
							onProcessCancel();
							return;
						}
						canceled = onProgress ? onProgress(step, numpixels, bmdToBytearray(canvas)) : false;
						if (canceled) {
							onProcessCancel();
							return;
						};
						var nextstep : uint = step + steps;
						while (step < nextstep) {
							// the process
							var x : int = Math.random() * _w;
							var y : int = Math.random() * _h;
							var color : uint = Math.random() * 0xFFFFFF;
							canvas.setPixel(x, y, color);
							// counter check
							step++;
							if (step == numpixels) {
								onProcessComplete();
								break;
							}
						}
//					}
//				);
			}
			// execute
//			batch.execute();
		}
	}
}
