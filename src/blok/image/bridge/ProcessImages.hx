package blok.image.bridge;

#if !blok.bridge
#error "Block Bridge is required to use this plugin"
#end
import blok.bridge.*;
import blok.context.Provider;
import blok.html.server.*;
import blok.ui.*;

using Kit;
using blok.image.ImageGenerator;
using haxe.io.Path;

class ProcessImages implements Plugin {
	@:constant final destination:String = '/assets/images';
	@:constant final mediumSize:Int = 800;
	@:constant final thumbSize:Int = 200;
	@:constant final engine:ImageEngine = Vips;

	var context:Null<ImageContext> = null;

	public function render(app:App, root:Child):Child {
		return Provider.provide(() -> context = new ImageContext({
			destination: destination
		})).child(_ -> root);
	}

	public function visited(app:App, path:String, document:NodePrimitive) {}

	public function output(app:App):Task<Nothing> {
		return Task
			.parallel(...[for (image in context.getEntries()) handleImage(app, image)])
			.next(_ -> Task.nothing());
	}

	public function cleanup():Void {
		// @todo: remove old images?
	}

	function handleImage(app:App, image:ImageEntry):Task<Nothing> {
		var out = app.output.directory(destination);
		return Task.parallel(
			app.fs.file(image.source).getMeta(),
			out.file(image.dest).getMeta()
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
					processImage(app, image);
				case false:
					Task.nothing();
			});
	}

	function processImage(app:App, image:ImageEntry):Task<Nothing> {
		return app.output.getMeta().next(meta -> {
			var out = Path.join([meta.path, image.dest]);
			switch image.size {
				case Full:
					app.fs.file(image.source)
						.copy(out)
						.next(_ -> Task.nothing());
				case Constrain(side, size):
					image.source.process(out, {
						engine: engine,
						width: size,
						height: size,
						crop: false
					}).next(_ -> Task.nothing());
				// case Thumbnail:
				// 	image.source.process(out, {
				// 		engine: engine,
				// 		width: thumbSize,
				// 		height: thumbSize,
				// 		crop: true
				// 	}).next(_ -> Task.nothing());
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
