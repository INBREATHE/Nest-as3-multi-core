package nest.utils
{
	public final class ArrayUtils
	{
		static public function shuffle( arr:Array ):void 
		{ // fisherYates
			var count:uint = arr.length,
				randomnumber:uint,
				temp:*;
			while( count ){
				randomnumber = Math.random() * count-- | 0;
				temp = arr[count];
				arr[count] = arr[randomnumber];
				arr[randomnumber] = temp
			}
		}
	}
}