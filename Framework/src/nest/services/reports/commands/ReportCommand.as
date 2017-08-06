/*
 NEST AS3 MultiCore
 Copyright (c) 2016 Vladimir Minkin <vladimir.minkin@gmail.com>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package nest.services.reports.commands
{
import nest.entities.application.ApplicationCommand;
import nest.patterns.command.SimpleCommand;

public class ReportCommand extends SimpleCommand
{
	protected final function Report(name:String, params:Object):void {
//		this.exec(ApplicationCommand.SINGLE_REPORT, params, name);
	}
}
}