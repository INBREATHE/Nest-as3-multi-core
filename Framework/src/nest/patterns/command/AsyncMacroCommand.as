/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.patterns.command
{
import nest.injector.Injector;
import nest.interfaces.IAsyncCommand;
import nest.interfaces.ICommand;
import nest.interfaces.INotifier;
import nest.patterns.observer.Notifier;

public class AsyncMacroCommand extends Notifier	implements IAsyncCommand
{
	private var _onComplete		:	Function;
	private var _subCommands	:	Vector.<Class>;
	private var _body			:	Object;
	private var _type			:	String;
	private var _counter		: 	int = 0;

	public function AsyncMacroCommand() {
		_subCommands = new Vector.<Class>();
	}

	override public function initializeNotifier(key:String):void {
		super.initializeNotifier(key);
		initializeAsyncMacroCommand();
	}

	protected function initializeAsyncMacroCommand():void { }
	protected function deInitializeAsyncMacroCommand():void {
		var commandClassRef:Class;
		_counter = _subCommands.length;
		const multitonKey:String = getMultitonKey();
		while(_counter--) {
			commandClassRef = _subCommands[_counter];
			Injector.unmapTarget(commandClassRef, multitonKey);
		}
		commandClassRef = null;
	}

	protected function addSubCommand( commandClassRef:Class ): void {
		const multitonKey:String = getMultitonKey();
		Injector.mapTarget(commandClassRef, multitonKey);
		_subCommands.push(commandClassRef);
	}
	protected function addSubCommands(classes:Vector.<Class>): void {
		const multitonKey:String = getMultitonKey();
		Injector.mapTargets(classes, multitonKey);
		_subCommands = _subCommands.concat(classes);
	}

	public function setOnComplete ( value:Function ) : void { _onComplete = value; }

	public final function execute( body:Object, type:String ) : void {
		this._body = body;
		this._type = type;
		ExecuteNextCommand();
	}

	private function ExecuteNextCommand():void {
		if (_subCommands.length > _counter) NextCommand();
		else {
			deInitializeAsyncMacroCommand();
			if(_onComplete != null) _onComplete();
			_body 			=	null;
			_onComplete		=	null;
			_subCommands 	= 	null;
			facade		 	= 	null;
		}
	}

	private function NextCommand () : void {
		const commandClassRef	:Class = Class(_subCommands[_counter++]);
		const commandInstance	:ICommand	= new commandClassRef();
		const multitonKey		:String = getMultitonKey();
		const isAsync			:Boolean = commandInstance is IAsyncCommand;

		commandInstance.initializeNotifier( multitonKey );
		if (isAsync) IAsyncCommand( commandInstance ).setOnComplete( ExecuteNextCommand );

		if(Injector.hasTarget(commandClassRef, multitonKey))
			Injector.injectTo( commandClassRef, commandInstance );

		commandInstance.execute( _body, _type );
		if (!isAsync) ExecuteNextCommand();
	}
}
}