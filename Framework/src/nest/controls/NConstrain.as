/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.controls
{
import flash.display.DisplayObject;

public class NConstrain extends DisplayObject
{
	static public var 
		LEFT		:Object = "left"
	,	RIGHT		:Object = "right"
	,	CENTER		:Object = "center"
	,	NONE		:Object = "none"
	,	TOP			:Object = "top"
	,	BOTTOM		:Object = "bottom"
	;
	
	public var constrainX:Object;
	public var constrainY:Object;
	
	public function NConstrain()
	{
	}
}
}