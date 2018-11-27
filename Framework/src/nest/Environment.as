package nest
{
	import flash.geom.Point;
	import flash.system.Capabilities;

	public final class Environment
	{
		public const isIOS			: Boolean = (Capabilities.manufacturer.indexOf("iOS") != -1);
		public const isAndroid	: Boolean = (Capabilities.manufacturer.indexOf("Android") != -1);
		
		public var isPhone			: Boolean;
		
		public var scaleFactor	    : Point;
		public var viewportSize	    : Point;
		public var textureSizeLimit	: uint;

		public function Environment()
		{
			
		}
	}
}