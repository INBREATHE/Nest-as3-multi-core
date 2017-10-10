/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.elements {
import nest.interfaces.IElement;

import starling.display.Sprite;

public class Element extends Sprite implements IElement {
    /* INTERFACE nest.interfaces.IElement */
    private var _order:int = 0;
    public function set order(value:int):void { _order = value; }
    public function get order():int { return _order; }
}
}
