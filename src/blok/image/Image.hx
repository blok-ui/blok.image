package blok.image;

import blok.html.Html;
import blok.ui.*;

class Image extends Component {
	@:observable final className:String = '';
	@:observable final src:String;
	@:observable final alt:String;
	@:observable final size:ImageSize = ImageSize.Full;

	function render():Child {
		var images = ImageContext.from(this);
		var dest = images.generateImagePath(src(), size());

		ImageContext.from(this).add(new ImageEntry({
			source: src(),
			size: size(),
			dest: dest
		}));

		return Html.img({
			className: className,
			src: dest,
			alt: alt
		});
	}
}
