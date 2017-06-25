/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.elements {
import nest.interfaces.IElement;

import starling.display.Sprite;

public class Element extends Sprite implements IElement{
    /* INTERFACE nest.interfaces.IElement */
    private var _prioritet:int = 0;
    public function set prioritet(value:int):void { _prioritet = value; }
    public function get prioritet():int { return _prioritet; }
}
}
