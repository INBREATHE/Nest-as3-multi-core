package nest.patterns.command {

import nest.patterns.command.body.CallbackCommandData;

public class CallbackCommand extends SimpleCommand
{
	private var _data:CallbackCommandData;

	//==================================================================================================
	override public function execute( body:Object, type:String ) : void {
	//==================================================================================================
		_data = body as CallbackCommandData;
		if( _data == null ) throw Error("Wrong body type - it must be: CallbackCommandData");
		process( _data.body );
	}

	public function process( body:Object ):void { }

	protected function Complete( ...params ):void {
		const func:Function = _data.OnComplete;
		if( params ) func.apply( null, params.splice(0) );
		else func();
		Dispose();
	}

	protected function Success( ...params ):void {
		const func:Function = _data.OnSuccess;
		if( params ) func.apply( null, params.splice(0) );
		else func();
	}

	protected function Error( ...params ):void {
		const func:Function = _data.OnError;
		if( params ) func.apply( null, params.splice(0) );
		else func();
	}

	private function Dispose():void {
		_data.dispose();
		_data = null;
	}
}
}



