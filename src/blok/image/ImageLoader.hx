package blok.image;

import blok.context.Context;

using Kit;

/**
	The ImageLoader lets you asynchronously load an image. On the server this 
	will do nothing, but on the client this will use the DOM to create a Task
	that resolves when an image is fully loaded.
**/
@:fallback(ImageLoader.instance())
class ImageLoader implements Context {
	public static function instance() {
		static var loader:Null<ImageLoader> = null;
		if (loader == null) loader = new ImageLoader();
		return loader;
	}

	#if blok.client
	final images:Map<String, Task<String>> = [];
	#end

	public function new() {}

	/**
		Load an image.

		The intended use for this is as a resource:

		```haxe
		class SomeComponent extends Component {
			@:attribute final src:String;
			@:resource final image:String = ImageLoader.from(this).load(src);

			function render() {
				return SuspenseBoundary.node({
					fallback: () -> 'Loading...',
					child: Scope.wrap(_ -> Html.img({src: image()}))
				});
			}
		}
		```
	**/
	public function load(src):Task<String> {
		#if blok.client
		return if (images.exists(src)) {
			images.get(src);
		} else {
			var img = new js.html.Image();
			img.src = src;

			var loader = if (img.complete) {
				Task.resolve(src);
			} else {
				new Task(activate -> {
					img.addEventListener('load', () -> activate(Ok(src)));
					img.addEventListener('error', _ -> activate(Error(new Error(NotFound, 'Image could not be found'))));
					if (img.complete) activate(Ok(src));
				});
			}

			images.set(src, loader);

			loader;
		}
		#else
		return Task.resolve(src);
		#end
	}

	public function dispose() {}
}
