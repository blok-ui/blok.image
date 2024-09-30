package blok.image.bridge;

import blok.bridge.Events.OutputEvent;
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

		bridge.events.outputting.add(event -> {
			var task = Task
				.parallel(...[for (image in context.getEntries()) handleImage(bridge, event, image)])
				.next(_ -> Task.nothing());
			event.enqueue(task);
		});
	}

	function handleImage(bridge:Bridge, event:OutputEvent, image:ImageEntry):Task<Nothing> {
		return Task.parallel(
			bridge.fs.file(image.source).getMeta(),
			bridge.output.file(image.path).getMeta()
		).next(files -> {
			switch files {
				case [source, dest] if (source.created.getTime() > dest.created.getTime()):
					// The source file is newer, so we need to reprocess the output.
					true;
				case [_, dest]:
					// The output image will not get processed, so we need to track it here
					// to let Bridge know we want to keep it.
					event.includeFile(dest.path);
					false;
				default:
					// Something went very wrong??
					false;
			}
		})
			.recover(_ -> {
				// If an output image was not found `getMeta` returns an error, so
				// we need to recover from it and generate an output image.
				Future.immediate(true);
			})
			.flatMap(shouldGenerate -> switch shouldGenerate {
				case true:
					processImage(bridge, event, image);
				case false:
					Task.nothing();
			});
	}

	function processImage(bridge:Bridge, event:OutputEvent, image:ImageEntry):Task<Nothing> {
		return bridge.output.getMeta().next(meta -> {
			var out = Path.join([meta.path, image.path]);
			event.includeFile(out);

			switch image.size {
				case Full:
					bridge.fs.file(image.source)
						.copy(out)
						.next(_ -> Task.nothing());
				case Constrain(side, size):
					// @todo: figure out how to actually constrain a side
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
