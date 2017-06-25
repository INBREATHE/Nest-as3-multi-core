/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.rasterizer
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import nest.utils.DisplayUtils;

public class RasterItem
{
	private var
		_id			: uint
	,	_lid		: String
	,	_type		: int
	,	_name		: String
	,	_child		: DisplayObject
	,	_rect		: Rectangle
	,	_bmd		: BitmapData
	,	_scale		: Number
	;

	public function RasterItem(
		id			: uint,
		lid			: String,
		type		: int,
		name		: String,
		child		: DisplayObject,
		position	: Point = null
	) {
		this._name = name;
		this._lid = lid;
		this._id = id;
		this._child = child;
		this._type = type;

		if (_child.parent!=null) {
			_bmd = DisplayUtils.displayObjectToBitmapData(child);
		} else {
			_bmd = rasterizeFromParent(child);
		}

		_rect = new Rectangle (
			position ? position.x : child.x,
			position ? position.y : child.y,
			child.width, child.height
		);
		_scale = 1;
	}

	public function resizeToFitWidth(value:uint):void
	{
		var tmpScale:Number = _child.scaleX;

		_scale = _bmd.width / value;
		_child.scaleX = _scale;
		_child.scaleY =  _scale;
		_bmd = DisplayUtils.displayObjectToBitmapData(_child);
		_rect.width = _child.width;
		_rect.height = _child.height;
		_scale *= tmpScale;
	}

	private function rasterizeFromParent(child:DisplayObject):BitmapData
	{
		var result:BitmapData;
		var fakeParent:Sprite = new Sprite();
		fakeParent.addChild(_child);
		result = DisplayUtils.displayObjectToBitmapData(fakeParent);
		fakeParent.removeChild(_child);
		return result;
	}

	public function getSize		(offset:uint = 0):uint { return (width + offset) * (height + offset); }

	public function get width	():uint 		{ return _rect.width; }
	public function get height	():uint 		{ return _rect.height; }
	public function get type	():int 			{ return _type; }
	public function get pos		():Point 		{ return _rect.topLeft; }
	public function get scale	():Number 		{ return _scale; }
	public function get id		():uint 		{ return _id; }
	public function get bmd		():BitmapData 	{ return _bmd; }
	public function get rect	():Rectangle 	{ return _rect; }
	public function get name	():String 		{ return _name; }
	public function get lid		():String  		{ return _lid; }
	public function get child	():DisplayObject { return _child; }
}
}