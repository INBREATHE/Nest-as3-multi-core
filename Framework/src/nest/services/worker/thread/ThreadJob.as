package nest.services.worker.thread
{
	public final class ThreadJob
	{
		public var 
			method		: Function
		,	params		: Array = null
		
		public function ThreadJob(method:Function, params:Array = null)
		{
			this.method = method;
			this.params = params;
		}
	}
}