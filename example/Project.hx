import hotdish.*;
import hotdish.node.*;
import blok.bridge.hotdish.*;
import blok.image.bridge.ProcessImages;

function main() {
	var version:SemVer = '0.0.1';
	var project = new Project({
		name: 'blok.image.example',
		version: version,
		url: '',
		contributors: ['wartman'],
		license: 'MIT',
		description: 'An example app',
		releasenote: 'Pre-release',
		children: [
			new Build({
				sources: ['example/src'],
				flags: {
					'dce': 'full',
					'analyzer-optimize': true,
					'debug': true
				},
				dependencies: [
					{name: 'blok.image'}
				],
				children: [
					new BuildBridge({
						bootstrap: 'ImageExample',
						version: version,
						plugins: [
							new ProcessImages({engine: Vips})
						],
						server: new BuildServer({
							dependencies: [
								{name: 'kit.file'}
							],
							children: [
								new StaticOutput({
									children: [
										new Run({}),
										new Hxml({name: 'build-example'})
									]
								})
							]
						})
					})
				]
			})
		]
	});

	project.run();
}
