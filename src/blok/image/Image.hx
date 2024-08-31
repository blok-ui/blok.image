package blok.image;

import blok.html.Html;
import blok.ui.*;

class Image extends Component {
	@:observable final className:String = '';
	@:observable final src:String;
	@:observable final alt:String;
	@:observable final size:ImageSize = ImageSize.Full;

	// @todo: Hm this won't work inside Islands.
	// How can we send Context to the client?
	function render():Child {
		var image = ImageContext.from(this).register(src(), size());

		return Html.img({
			className: className,
			src: image.path,
			alt: alt
		});
	}
}
