import blok.bridge.Bridge;
import blok.bridge.plugin.*;
import blok.image.bridge.ProcessImages;

function main() {
	Bridge.start({
		version: '0.0.1',
		outputPath: 'dist/www'
	})
		.plugins([
			new StaticHtml({
				strategy: DirectoryWithIndexHtmlFile
			}),
			new ClientApp({
				flags: ['-dce full', '-D analyzer-optimize'],
				dependencies: InheritDependencies
			}),
			new ProcessImages({
				engine: Vips
			}),
			new Logging()
		])
		.generate(() -> ImageExample.node({}))
		.handle(result -> switch result {
			case Ok(_): trace('done');
			case Error(error): trace(error.message);
		});
}
