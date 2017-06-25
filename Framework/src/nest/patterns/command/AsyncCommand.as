/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.command
{
import nest.interfaces.IAsyncCommand;
import nest.patterns.command.SimpleCommand;

public class AsyncCommand extends SimpleCommand	implements IAsyncCommand
{
	public function setOnComplete ( value:Function ) : void {
		_onComplete = value;
	}

	protected function commandComplete () : void {
		_onComplete();
		_onComplete = null;
	}

	private var _onComplete	:	Function;

}
}
