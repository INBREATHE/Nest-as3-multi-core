/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.interfaces
{
import nest.entities.popup.PopupAction;
import nest.entities.popup.PopupData;

public interface IPopup extends IEntity
{
	function setup( data:PopupData ):void;
	function prepare( params:Object ):void;
	function show():void;
	function clear():void;
	function hide( next:Function ):void;
	function addAction( action:PopupAction ):void;
	function getAction( actionID:String ):PopupAction;
}
}
