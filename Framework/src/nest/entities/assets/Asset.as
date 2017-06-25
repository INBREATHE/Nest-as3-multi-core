/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.entities.assets
{

import starling.display.Button;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

public class Asset
{
	public var classlink:Class;
	public var type:int = int.MAX_VALUE;
	public var obj:* = null;

	public function Asset(type:int, classlink:Class) {
		this.type = type;
		this.classlink = classlink;
	}

	/**
	 * Return texture from Image obj
	 * for Button return only upState texture
	 */
	public function get texture():Texture {
		var result:Texture;
		if(obj is Image) result = Image(obj).texture;
		else if(obj is Button) result = Button(obj).upState;
		return result;
	}

	public function get clone():* {
		var result:DisplayObject;
		if (obj is Button) result = new Button(Button(obj).upState, "", Button(obj).downState);
		else if (obj is Image) result = new Image(Image(obj).texture);
		return result;
	}
}
}
