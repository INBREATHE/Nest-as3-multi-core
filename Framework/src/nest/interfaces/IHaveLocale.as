/**
 * Created by Vladimir Minkin on 21.09.2017.
 */
package nest.interfaces
{
	public interface IHaveLocale
	{
	    function getLocaleID():String;
	    function localize( localeData:XMLList ):void;
	}
}
