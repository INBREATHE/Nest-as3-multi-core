package nest.utils
{
	public final class ArrayUtils
	{
		static public function shuffle( arr:Object ):void
		{ // fisherYates
			var count:uint = arr.length,
				random:uint,
				temp:*;
			while( count ) {
				random = Math.random() * count-- | 0;
				temp = arr[ count ];
				arr[ count ] = arr[ random ];
				arr[ random ] = temp;
			}
		}
	}
}