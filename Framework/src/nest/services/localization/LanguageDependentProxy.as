/**
 * Created by DQvsRA on 19.09.2017.
 */
package nest.services.localization {

import nest.interfaces.ILanguageDependent;
import nest.patterns.proxy.Proxy;

public class LanguageDependentProxy extends Proxy implements ILanguageDependent
{
	public function LanguageDependentProxy(data:Object = null):void { super(data); }
	
    /**
     *  This method should be called only from Model
     *  which triggered in facade, from currentLanguage setter)
    */
    public function languageChanged():void { }
}
}
