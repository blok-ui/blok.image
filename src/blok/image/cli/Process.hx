package blok.image.cli;

#if nodejs
import js.node.ChildProcess;
#end

using Kit;

class Process {
	final task:Task<Int>;

	public function new(cmd:String, args:Array<String>) {
		task = new Task(activate -> {
			#if nodejs
			var process = ChildProcess.spawn(cmd, args);
			process.on('exit', (code, _) -> {
				activate(Ok(code));
			});
			#else
			var process = new sys.io.Process(cmd, args);
			activate(Ok(process.exitCode()));
			#end
		});
	}

	public inline function getTask() {
		return task;
	}
}
