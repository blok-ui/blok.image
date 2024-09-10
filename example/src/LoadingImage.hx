import blok.image.Image;
import blok.suspense.SuspenseBoundary;
import blok.image.ImageLoader;
import blok.bridge.Island;
import blok.ui.*;

class LoadingImage extends Island {
	@:attribute final src:String;
	@:resource final image:String = ImageLoader.from(this).load(src);

	function render():Child {
		return SuspenseBoundary.node({
			// @todo: this will break hydration
			child: Scope.wrap(_ -> Image.node({src: image(), alt: 'Image'})),
			fallback: () -> 'Loading'
		});
	}
}
