package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitSet:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		if (PlayState.SONG.song.toLowerCase() != 'training-with-gf')
		{
			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}, 5);
		}

		if (PlayState.SONG.song.toLowerCase()=='senpai' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='thorns')
		{
			box = new FlxSprite(-20, 45);
		}
		else
		{
			box = new FlxSprite(-20,350);
		}
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear instance 1', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH instance 1', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn instance 1', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			case 'training-with-gf':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'Speech Bubble Normal Open', [4], "", 24);
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubbles');
				box.animation.addByPrefix('normalOpen', 'eli speech', 24, false);
				box.animation.addByPrefix('normal', 'eli speech', 24, false);
				box.animation.addByPrefix('eli', 'eli speech', 24, false);
				box.animation.addByPrefix('hex', 'hex speech', 24, false);
				box.animation.addByPrefix('eli2', 'eli2 speech', 24, false);
				box.animation.addByPrefix('bf', 'bf speech', 24, false);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;

			portraitRight = new FlxSprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;

			box.animation.play('normalOpen');
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			box.updateHitbox();
			add(box);

			box.screenCenter(X);
			portraitLeft.screenCenter(X);
		}
		else if (PlayState.SONG.song.toLowerCase() != 'training-with-gf')
		{
			portraitSet = new FlxSprite(0, 0);
			portraitSet.frames = Paths.getSparrowAtlas('portraitSet');
			portraitSet.animation.addByPrefix('eli', 'eli speech', 24, false);
			portraitSet.animation.addByPrefix('hex', 'hex speech', 24, false);
			portraitSet.animation.addByPrefix('eli2', 'eli2 speech', 24, false);
			portraitSet.animation.addByPrefix('bf', 'bf speech', 24, false);

			portraitSet.animation.play('eli');

			add(portraitSet);

			portraitSet.screenCenter();
			portraitSet.x -= 50;
			portraitSet.y += 50;

			box.animation.play('normalOpen');
			add(box);

			box.screenCenter(X);

			portraitLeft = new FlxSprite(130, 120);
			portraitLeft.frames = Paths.getSparrowAtlas('hexPortrait');
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom *0.18));
			portraitLeft.animation.addByPrefix('enter', 'Hex Portrait Normal', 24, false);
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
	
			portraitRight = new FlxSprite(750, 120);
			portraitRight.frames = Paths.getSparrowAtlas('eliPortrait');
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom *0.18));
			portraitRight.animation.addByPrefix('enter', 'Eli Portrait Normal', 24, false);
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
			portraitRight.flipX = true;
			
			box.animation.play('normalOpen');
			add(box);
	
			box.screenCenter(X);
		}
		else
		{
			portraitSet = new FlxSprite(0, 0);
			portraitSet.frames = Paths.getSparrowAtlas('portraitSet');
			portraitSet.animation.addByPrefix('eli', 'eli speech', 24, false);
			portraitSet.animation.addByPrefix('hex', 'hex speech', 24, false);
			portraitSet.animation.addByPrefix('eli2', 'eli2 speech', 24, false);
			portraitSet.animation.addByPrefix('bf', 'bf speech', 24, false);

			portraitSet.animation.play('eli');

			add(portraitSet);

			portraitSet.screenCenter();
			portraitSet.x -= 50;
			portraitSet.y += 50;
			portraitSet.visible = false;
			
			portraitLeft = new FlxSprite(130, 120);
			portraitLeft.frames = Paths.getSparrowAtlas('hexPortrait');
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom *0.18));
			portraitLeft.animation.addByPrefix('enter', 'Hex Portrait Normal', 24, false);
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;
	
			portraitRight = new FlxSprite(750, 120);
			portraitRight.frames = Paths.getSparrowAtlas('eliPortrait');
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom *0.18));
			portraitRight.animation.addByPrefix('enter', 'Eli Portrait Normal', 24, false);
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
			portraitRight.flipX = true;
			
			box.animation.play('normalOpen');
			add(box);
	
			box.screenCenter(X);
		}

		handSelect = new FlxSprite(1042, 590).loadGraphic(Paths.getPath('images/weeb/pixelUI/hand_textbox.png', IMAGE));
		handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
		handSelect.updateHitbox();
		handSelect.visible = false;
		add(handSelect);

		var splitName:Array<String> = dialogueList[0].split(":");

		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
			dropText.font = 'Pixel Arial 11 Bold';
			dropText.color = 0xFFD89494;
			add(dropText);

			swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
			swagDialogue.font = 'Pixel Arial 11 Bold';
			swagDialogue.color = 0xFF3F2021;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
			add(swagDialogue);
		}
		else
		{
			dropText = new FlxText(0, 477, Std.int(FlxG.width * 0.8), "", 100);
			dropText.font = 'Elistyleremastered Regular';
			dropText.color = 0xFF808080;
			add(dropText);
			dropText.screenCenter(X);
			dropText.x += 2;
	
			swagDialogue = new FlxTypeText(0, 475, Std.int(FlxG.width * 0.8), "", 100);
			swagDialogue.font = 'Elistyleremastered Regular';
			swagDialogue.color = FlxColor.BLACK;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound(splitName[1] + 'Text'), 0.6)];
			add(swagDialogue);
			swagDialogue.screenCenter(X);
		}
		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(FlxG.keys.justPressed.ANY)
		{
			if (dialogueEnded)
			{
				remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
						{
							FlxG.sound.play(Paths.sound('clickText'), 0.8);
						}
						else
						{
							FlxG.sound.play(Paths.sound('popText'), 1);
						}

						if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
							FlxG.sound.music.fadeOut(1.5, 0);

						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							portraitSet.visible = false;
							swagDialogue.alpha -= 1 / 5;
							handSelect.alpha -= 1 / 5;
							dropText.alpha = swagDialogue.alpha;
						}, 5);

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
					{
						FlxG.sound.play(Paths.sound('clickText'), 0.8);
					}
					else
					{
						FlxG.sound.play(Paths.sound('popText'), 1);
					}
				}
			}
			else if (dialogueStarted)
			{
				if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
				{
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
				}
				else
				{
					FlxG.sound.play(Paths.sound('popText'), 1);
				}
				swagDialogue.skip();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			handSelect.visible = true;
			dialogueEnded = true;
		};

		handSelect.visible = false;
		dialogueEnded = false;
		switch (curCharacter)
		{
			case 'dad' | 'eli' | 'hex' | 'gf':
				if (PlayState.SONG.song.toLowerCase() != 'training-with-gf')
				{
					if (PlayState.SONG.song.toLowerCase() != 'senpai' && PlayState.SONG.song.toLowerCase() != 'roses' && PlayState.SONG.song.toLowerCase() != 'thorns')
					{
						box.animation.play(curCharacter);
						portraitSet.animation.play(curCharacter);
					}
					else
					{
						portraitRight.visible = false;
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.animation.play('enter');
						}
					}
				}
				else
				{
					box.flipX = true;
				}

				swagDialogue.sounds = [FlxG.sound.load(Paths.sound(curCharacter + 'Text'), 0.6)];

			case 'bf' | 'eli2':
				if (PlayState.SONG.song.toLowerCase() != 'training-with-gf')
				{	
					if (PlayState.SONG.song.toLowerCase() != 'senpai' && PlayState.SONG.song.toLowerCase() != 'roses' && PlayState.SONG.song.toLowerCase() != 'thorns')
					{
						box.animation.play(curCharacter);
						portraitSet.animation.play(curCharacter);
					}
					else
					{
						portraitLeft.visible = false;
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.animation.play('enter');
						}
					}
				}
				else
				{
					box.flipX = false;
				}

				swagDialogue.sounds = [FlxG.sound.load(Paths.sound(curCharacter + 'Text'), 0.6)];
		}
		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
