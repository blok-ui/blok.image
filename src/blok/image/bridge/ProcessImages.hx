package blok.image.bridge;

import blok.context.Provider;
import blok.data.Structure;
import blok.bridge.*;

using Kit;
using blok.image.ImageGenerator;
using haxe.io.Path;

class ProcessImages extends Structure implements Plugin {
	@:constant final destination:String = '/assets/images';
	@:constant final engine:ImageEngine = Vips;

	public function register(bridge:Bridge) {
		var context = new ImageContext({destination: destination});

		bridge.events.rendering.add(event -> {
			event.apply(child -> Provider.provide(() -> context).child(_ -> child));
		});

		bridge.events.outputting.add(queue -> {
			var task = Task
				.parallel(...[for (image in context.getEntries()) handleImage(bridge, image)])
				.next(_ -> Task.nothing());
			queue.enqueue(task);
		});
	}

	function handleImage(bridge:Bridge, image:ImageEntry):Task<Nothing> {
		var out = bridge.output.directory(destination);
		return Task.parallel(
			bridge.fs.file(image.source).getMeta(),
			out.file(image.path).getMeta()
		).next(files -> {
			switch files {
				case [source, dest] if (source.created.getTime() > dest.created.getTime()):
					true;
				default:
					false;
			}
		})
			.recover(_ -> Future.immediate(true))
			.flatMap(shouldGenerate -> switch shouldGenerate {
				case true:
					processImage(bridge, image);
				case false:
					Task.nothing();
			});
	}

	function processImage(bridge:Bridge, image:ImageEntry):Task<Nothing> {
		return bridge.output.getMeta().next(meta -> {
			var out = Path.join([meta.path, image.path]);
			switch image.size {
				case Full:
					bridge.fs.file(image.source)
						.copy(out)
						.next(_ -> Task.nothing());
				case Constrain(side, size):
					image.source.process(out, {
						engine: engine,
						width: size,
						height: size,
						crop: false
					}).next(_ -> Task.nothing());
				case Crop(x, y):
					image.source.process(out, {
						engine: engine,
						width: x,
						height: y,
						crop: true
					}).next(_ -> Task.nothing());
			}
		});
	}
}
