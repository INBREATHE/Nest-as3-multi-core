package nest.services.worker.thread 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	/** 
	 * 
	 * The PseudoThread is a simple timer based multithreading class to execute batch of serial jobs through the queue
	 * 
	 * @author Bagus
	 * @mail bagus@signt.com
	 * 
	 */
	 
	public class Thread 
	{
		private const _jobs : Vector.<ThreadJob> = new Vector.<ThreadJob>()
		private const _timer : Timer = new Timer(0);
		
		private var 
			_isRunning 		: Boolean = false
		,	_iteration 		: int = 1

		/**
		 * Creates timer based pseudo thread instance.
		 * 
		 * @param waitingtime The amount of delay time before execute the next job in miliseconds
		 * @param iteration The number of job batch to be executed when timer triggered.
		 * 
		 */
		
		public function Thread(waitingtime:int=0, iteration:int=1) 
		{
			_iteration = iteration;
			_timer.delay = waitingtime;
		}
		
		/**
		 * Adding job to the queue
		 * 
		 * @param method The method or abstract function to be execute
		 * @param params the method arguments
		 * 
		 */		
		
		final public function add(method:Function, params:Array=null):void {
			_jobs.push( new ThreadJob(method, params) );
		}
		
		final private function doJob(event:TimerEvent = null):void {
			if (!_isRunning) return;
			if(_timer.hasEventListener(TimerEvent.TIMER)) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, doJob);
			}
			var iterations:uint = _iteration;
			var job:ThreadJob, method:Function;
			while(iterations--){
				if (_isRunning && _jobs.length > 0) {
					job = _jobs.shift();
					method = job.method;
					method.apply(null, job.params);
				} else {
					_isRunning = false;
					break;
				}
			}
			if (_jobs.length) loadJob();
		}

		final private function loadJob():void {
			if (_isRunning && !_timer.hasEventListener(TimerEvent.TIMER)) {
				_timer.addEventListener(TimerEvent.TIMER, doJob);
				_timer.start();
			}
		}
		
		/**
		 * execute the all jobs in the queue
		 */	
		final public function execute():void {
			if(!_isRunning) {
				_isRunning = true;
				loadJob();
			}
		}
		
		/**
		 * stopping execution and clearing the queue
		 */		
		
		public function stop():void {
			if(_isRunning) {
				_isRunning = false;
				_jobs.splice(0, _jobs.length);
			}
		}		
	}

}