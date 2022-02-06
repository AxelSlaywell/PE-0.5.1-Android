package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;

		var library:String = null;
		switch (curCharacter)
		{
			//case 'bf-street':
			//	frames = Paths.getSparrowAtlas('BOYFRIENDSTREET');
			//	animation.addByPrefix('idle', 'BF idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
			//	animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
			//	animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
			//	animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
			//	animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
			//	animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
			//	animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
			//	animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
			//	animation.addByPrefix('hey', 'BF HEY', 24, false);
		//
			//	animation.addByPrefix('firstDeath', "BF dies", 24, false);
			//	animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
			//	animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
		//
			//	animation.addByPrefix('scared', 'BF idle shaking', 24);
	//
			//	animation.addByPrefix('hit', 'BF hit', 24, false);
		//
			//	addOffset('idle', -1);
			//	addOffset("singUP", -31, 30);
			//	addOffset("singRIGHT", -38, -5);
			//	addOffset("singLEFT", 12, -6);
			//	addOffset("singDOWN", -10, -43);
			//	addOffset("singUPmiss", -29, 16);
			//	addOffset("singRIGHTmiss", -30, 10);
			//	addOffset("singLEFTmiss", 12, 18);
			//	addOffset("singDOWNmiss", -11, -33);
			//	addOffset("hey", 1, -1);
			//	addOffset('firstDeath', 37, 22);
			//	addOffset('deathLoop', 37, 25);
			//	addOffset('deathConfirm', 37, 43);
			//	addOffset('scared', 0, -3);
			//	addOffset('hit', 9, 2);
		//
			//	playAnim('idle');
		//
			//	flipX = true;

			//case 'bf-eli':
			//	frames = Paths.getSparrowAtlas('PlayableEli');
			//	animation.addByPrefix('idle', 'BF idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
			//	animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
			//	animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
			//	animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
			//	animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
			//	animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
			//	animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
			//	animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
			//	animation.addByPrefix('hey', 'BF HEY', 24, false);
		//
			//	animation.addByPrefix('firstDeath', "BF dies", 24, false);
			//	animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
			//	animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
		//
			//	animation.addByPrefix('scared', 'BF idle shaking', 24);
	//
			//	animation.addByPrefix('hit', 'BF hit', 24, false);
		//
			//	addOffset('idle', -5);
			//	addOffset("singUP", -29, 10);
			//	addOffset("singRIGHT", -50, -3);
			//	addOffset("singLEFT", 12, -11);
			//	addOffset("singDOWN", 13, -50);
			//	addOffset("singUPmiss", -39, 13);
			//	addOffset("singRIGHTmiss", -35, -1);
			//	addOffset("singLEFTmiss", 29, -15);
			//	addOffset("singDOWNmiss", -20, -29);
			//	addOffset("hey", -9, -3);
			//	addOffset('firstDeath', -2, 21);
			//	addOffset('deathLoop', -2, 21);
			//	addOffset('deathConfirm', -2, 21);
			//	addOffset('scared', -12, 0);
			//	addOffset('hit', 16, -12);
		//
			//	playAnim('idle');
		//
			//	flipX = true;
//
			//case 'bf-remix':
			//	frames = Paths.getSparrowAtlas('remix_bf');
			//	animation.addByPrefix('idle', 'BF idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
			//	animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
			//	animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
			//	animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
			//	animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
			//	animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
			//	animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
			//	animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
			//	animation.addByPrefix('hey', 'BF HEY', 24, false);
		//
			//	animation.addByPrefix('firstDeath', "BF dies", 24, false);
			//	animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
			//	animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
		//
			//	animation.addByPrefix('scared', 'BF idle shaking', 24);
		//
			//	animation.addByPrefix('hit', 'BF hit', 24, false);
		//
			//	addOffset('idle', -1);
			//	addOffset("singUP", -31, 30);
			//	addOffset("singRIGHT", -38, -5);
			//	addOffset("singLEFT", 12, -6);
			//	addOffset("singDOWN", -10, -43);
			//	addOffset("singUPmiss", -29, 16);
			//	addOffset("singRIGHTmiss", -30, 10);
			//	addOffset("singLEFTmiss", 12, 18);
			//	addOffset("singDOWNmiss", -11, -33);
			//	addOffset("hey", 1, -1);
			//	addOffset('firstDeath', 37, 22);
			//	addOffset('deathLoop', 37, 25);
			//	addOffset('deathConfirm', 37, 43);
			//	addOffset('scared', 0, -3);
			//	addOffset('hit', 9, 2);
		//
			//	playAnim('idle');
		//
			//	flipX = true;
//
			//case 'bf-eli-remix':
			//	frames = Paths.getSparrowAtlas('PlayableEliRemix');
			//	animation.addByPrefix('idle', 'BF idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
			//	animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
			//	animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
			//	animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
			//	animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
			//	animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
			//	animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
			//	animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
			//	animation.addByPrefix('hey', 'BF HEY', 24, false);
		//
			//	animation.addByPrefix('firstDeath', "BF dies", 24, false);
			//	animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
			//	animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
		//
			//	animation.addByPrefix('scared', 'BF idle shaking', 24);
		//
			//	animation.addByPrefix('hit', 'BF hit', 24, false);
		//
			//	addOffset('idle', -5);
			//	addOffset("singUP", -29, 10);
			//	addOffset("singRIGHT", -50, -3);
			//	addOffset("singLEFT", 12, -11);
			//	addOffset("singDOWN", 13, -50);
			//	addOffset("singUPmiss", -39, 13);
			//	addOffset("singRIGHTmiss", -35, -1);
			//	addOffset("singLEFTmiss", 29, -15);
			//	addOffset("singDOWNmiss", -20, -29);
			//	addOffset("hey", -9, -3);
			//	addOffset('firstDeath', -2, 21);
			//	addOffset('deathLoop', -2, 21);
			//	addOffset('deathConfirm', -2, 21);
			//	addOffset('scared', -12, 0);
			//	addOffset('hit', 16, -12);
		//
			//	playAnim('idle');
		//
			//	flipX = true;
	//
			case 'bf-gb':

				frames = Paths.getSparrowAtlas('bfGB');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
	
				addOffset('idle');
				addOffset("singUP", -2, 3);
				addOffset("singRIGHT", -4);
				addOffset("singLEFT", 6);
				addOffset("singDOWN", 1, -2);
				addOffset("singUPmiss", 0, 3);
				addOffset("singRIGHTmiss", -5, 1);
				addOffset("singLEFTmiss", 4, 0);
				addOffset("singDOWNmiss", 0, -1);
				addOffset('firstDeath', 11, 2);
				addOffset('deathLoop', 6);
				addOffset('deathConfirm', -4, 3);

				setGraphicSize(Std.int(width * 1.5));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				flipX = true;

			//case 'eli':
//
			//	frames = Paths.getSparrowAtlas('ELI');
			//	animation.addByPrefix('idle', 'Eli idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'Eli up pose', 24, false);
			//	animation.addByPrefix('singRIGHT', 'Eli right pose', 24, false);
			//	animation.addByPrefix('singDOWN', 'Eli down pose', 24, false);
			//	animation.addByPrefix('singLEFT', 'Eli left pose', 24, false);
			//	animation.addByPrefix('snap', 'Eli snap', 24, false);
	//
			//	addOffset('idle', 5, -1);
			//	addOffset("singUP", -6, 51);
			//	addOffset("singRIGHT", -9, 35);
			//	addOffset("singLEFT", 24, -6);
			//	addOffset("singDOWN", 0, -30);
			//	addOffset('snap', 248, 8);
			//	playAnim('idle');
	//
			case 'eli-gb':

				frames = Paths.getSparrowAtlas('eliGB');
				animation.addByPrefix('idle', 'k idle', 24, false);
				animation.addByPrefix('singUP', 'k up', 24, false);
				animation.addByPrefix('singRIGHT', 'k right', 24, false);
				animation.addByPrefix('singDOWN', 'k down', 24, false);
				animation.addByPrefix('singLEFT', 'k left', 24, false);
				addOffset('idle', 0, 0);
				addOffset("singUP", 0, 0);
				addOffset("singRIGHT", 0, 0);
				addOffset("singLEFT", 0, 0);
				addOffset("singDOWN", 0, 0);

				playAnim('idle');

				setGraphicSize(Std.int(width * 1.5), Std.int(height*1.5));
				updateHitbox();

				antialiasing = false;
	//
			//case 'eli-remix':
			//
			//	frames = Paths.getSparrowAtlas('drip_eli');
//
			//	animation.addByPrefix('idle', 'Eli idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'Eli up pose', 24, false);
			//	animation.addByPrefix('singRIGHT', 'Eli right pose', 24, false);
			//	animation.addByPrefix('singDOWN', 'Eli down pose', 24, false);
			//	animation.addByPrefix('singLEFT', 'Eli left pose', 24, false);
			//	animation.addByPrefix('snap', 'Eli snap', 24, false);
		//
			//	addOffset('idle');
			//	addOffset("singUP", -78, 77);
			//	addOffset("singRIGHT", -16, 3);
			//	addOffset("singLEFT", -11, -65);
			//	addOffset("singDOWN", 42, -64);
			//	addOffset('snap', 178, 10);
			//	playAnim('idle');

			//case 'ei':
			//	
			//	frames = Paths.getSparrowAtlas('ei_no_squish');
//
			//	animation.addByPrefix('idle', 'ei idle dance', 24, false);
			//	animation.addByPrefix('singUP', 'ei up pose', 24, false);
			//	animation.addByPrefix('singRIGHT', 'ei right pose', 24, false);
			//	animation.addByPrefix('singDOWN', 'ei down pose', 24, false);
			//	animation.addByPrefix('singLEFT', 'ei left pose', 24, false);
		//
			//	addOffset('idle', 5, -1);
			//	addOffset("singUP", 25, 35);
			//	addOffset("singRIGHT", -9, 15);
			//	addOffset("singLEFT", 130, -11);
			//	addOffset("singDOWN", 53, -150);
			//	playAnim('idle');
			//	
			//case 'hex':
//
			//	frames = Paths.getSparrowAtlas('HEX_ASSETS');
//
			//	animation.addByPrefix('idle', 'Hex idle', 24, false);
			//	animation.addByPrefix('singUP', 'Hex up', 24, false);
			//	animation.addByPrefix('singRIGHT', 'Hex right', 24, false);
			//	animation.addByPrefix('singDOWN', 'Hex down', 24, false);
			//	animation.addByPrefix('singLEFT', 'Hex left', 24, false);
		//
			//	addOffset('idle');
			//	addOffset("singUP", -96, 14);
			//	addOffset("singRIGHT", -100, -30);
			//	addOffset("singLEFT", -92, -57);
			//	addOffset("singDOWN", -172, -116);
		//
			//	playAnim('idle');
//
			//	case 'hex-remix':
//
			//		frames = Paths.getSparrowAtlas('HEX_ASSETS_REMIX');
	//
			//		animation.addByPrefix('idle', 'Hex idle', 24, false);
			//		animation.addByPrefix('singUP', 'Hex up', 24, false);
			//		animation.addByPrefix('singRIGHT', 'Hex right', 24, false);
			//		animation.addByPrefix('singDOWN', 'Hex down', 24, false);
			//		animation.addByPrefix('singLEFT', 'Hex left', 24, false);
			//
			//		addOffset('idle');
			//		addOffset("singUP", -96, 14);
			//		addOffset("singRIGHT", -100, -30);
			//		addOffset("singLEFT", -92, -57);
			//		addOffset("singDOWN", -172, -116);
			//
			//		playAnim('idle');

			case 'street-gf':
				
				frames = Paths.getSparrowAtlas('StreetGF_assets');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);
	
				addOffset('cheer');
				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);
	
				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);
	
				addOffset('scared', -2, -17);
	
				playAnim('danceRight');
	
			case 'speakers':

				frames = Paths.getSparrowAtlas('SPEAKERS');
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		
				addOffset('danceLeft', 0, -275);
				addOffset('danceRight', 0, -275);
		
		
				playAnim('danceRight');
	
			case 'gf-remix':

				frames = Paths.getSparrowAtlas('remix_gf');
				
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
		
				addOffset('danceLeft');
				addOffset('danceRight');
				addOffset('sad', -2, -11);
	
		
		
				playAnim('danceRight');

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';
				#if MODS_ALLOWED
				var path:String = Paths.mods(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				if(Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT))) {
					frames = Paths.getPackerAtlas(json.image);
				} else {
					frames = Paths.getSparrowAtlas(json.image);
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing)
					noAntialiasing = true;

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}
				//trace('Loaded file to character ' + curCharacter);
		}
		originalFlipX = flipX;

		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			/*if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}*/
		}
	}

	override function update(elapsed:Float)
	{
		
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf') || curCharacter.endsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function recalculateDanceIdle() {
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
