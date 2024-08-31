package blok.image;

import blok.debug.Debug;
import blok.context.Context;

using Lambda;
using haxe.io.Path;
using kit.Hash;

@:fallback(error(
	'No image context was provided.'
	#if blok.bridge
	+ ' Make sure the `blok.image.bridge.ProcessImages` plugin is added'
	+ ' to your configuration.'
	#end
))
class ImageContext implements Context {
	final destination:String;
	final entries:Array<ImageEntry> = [];

	public function new(options) {
		this.destination = options.destination;
	}

	public inline function register(source:String, size:ImageSize):ImageEntry {
		var path = generateImagePath(source, size);
		return entries.find(entry -> entry.path == path) ?? {
			var entry = new ImageEntry({
				source: source,
				size: size,
				path: path
			});
			entries.push(entry);
			entry;
		}
	}

	public function getEntries() {
		return entries;
	}

	public function generateImagePath(path:String, size:ImageSize) {
		var ext = path.extension();
		var suffix = switch size {
			case Full: 'full';
			case Constrain(side, size): 'constrain-${side}-${size}';
			case Crop(x, y): 'crop-$x-$y';
		}
		var name = (path + suffix).hash();
		return Path.join([destination, name]).withExtension(ext);
	}

	public function dispose() {}
}
