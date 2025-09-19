package states;

import backend.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class FreeplayState extends MusicBeatState
{
	var freeplayButtons:FlxTypedGroup<FlxSprite>;
	var icons:FlxTypedGroup<FlxSprite>;
	var buttonScale:Float = 1.12;
	var hoverScaleFactor:Float = 1.1;
	var hoverScale:Float;
	var buttonCallbacks:Map<FlxSprite, Void->Void> = new Map();
	var blackTransition:FlxSprite;
	var transitioning:Bool = false;
	var lastHovered:FlxSprite = null;

	var bg:FlxSprite;
	var bgColors:Array<Int> = [0xFF99E550, FlxColor.WHITE, 0xFFD1D1D1];

	override function create()
	{
		super.create();

		hoverScale = buttonScale * hoverScaleFactor;
		FlxG.mouse.visible = true;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.antialiasing = false;
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = bgColors[0];
		add(bg);

		freeplayButtons = new FlxTypedGroup<FlxSprite>();
		icons = new FlxTypedGroup<FlxSprite>();
		add(freeplayButtons);
		add(icons);

		var atlas = Paths.getSparrowAtlas("menuButtons/freeplayButtons");
		var buttonX:Float = 190;
		var buttonYStart:Float = 90;
		var buttonSpacing:Float = 180;

		addButton(atlas, "the-necessary", buttonX, buttonYStart + 0 * buttonSpacing, function()
		{
			PlayState.SONG = Song.loadFromJson("the-necessary", "the-necessary");
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			startTransition(new PlayState());
		}, "icon-darn");

		addButton(atlas, "placeholder", buttonX, buttonYStart + 1 * buttonSpacing, function()
		{
			PlayState.SONG = Song.loadFromJson("placeholder", "placeholder");
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			startTransition(new PlayState());
		}, "icon-whitedude");

		addButton(atlas, "song-1", buttonX, buttonYStart + 2 * buttonSpacing, function()
		{
			PlayState.SONG = Song.loadFromJson("song-1", "song-1");
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			startTransition(new PlayState());
		}, "icon-thegirlslol");

		blackTransition = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackTransition.alpha = 1;
		add(blackTransition);

		FlxTween.tween(blackTransition, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
	}

	function addButton(atlas:FlxAtlasFrames, frameName:String, x:Float, y:Float, onClick:Void->Void, iconName:String):Void
	{
		var btn = makeButton(atlas, frameName, x, y, onClick);
		freeplayButtons.add(btn);

		var icon = new FlxSprite(btn.x + btn.width + 20, btn.y);
		icon.loadGraphic(Paths.image("icons/" + iconName));
		icon.antialiasing = false;
		icon.scale.set(1.12, 1.12);
		icon.updateHitbox();
		icon.clipRect = new FlxRect(0, 0, 150, 150);
		icons.add(icon);
	}

	function makeButton(atlas:FlxAtlasFrames, frameName:String, x:Float, y:Float, onClick:Void->Void):FlxSprite
	{
		var btn = new FlxSprite(x, y);
		btn.frames = atlas;
		btn.animation.addByPrefix("idle", frameName, 0, false);
		btn.animation.play("idle");
		btn.origin.set(btn.width / 2, btn.height / 2);
		btn.x += btn.width / 2;
		btn.y += btn.height / 2;
		btn.scale.set(buttonScale, buttonScale);
		btn.setGraphicSize(Std.int(btn.width * buttonScale));
		btn.updateHitbox();
		btn.antialiasing = false;

		buttonCallbacks.set(btn, onClick);
		return btn;
	}

	function startTransition(nextState:FlxState):Void
	{
		if (transitioning)
			return;

		transitioning = true;
		FlxTween.tween(blackTransition, {alpha: 1}, 0.5, {
			ease: FlxEase.quadIn,
			onComplete: function(_) FlxG.switchState(nextState)
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mousePos = FlxG.mouse.getScreenPosition();
		var idx = 0;

		for (btn in freeplayButtons)
		{
			var isHovered = btn.overlapsPoint(mousePos, true, FlxG.camera);
			var targetScale = isHovered ? hoverScale : buttonScale;
			var center = btn.getMidpoint();

			btn.scale.x += (targetScale - btn.scale.x) * 0.15;
			btn.scale.y += (targetScale - btn.scale.y) * 0.15;
			btn.setGraphicSize(Math.round(btn.frameWidth * btn.scale.x), Math.round(btn.frameHeight * btn.scale.y));
			btn.updateHitbox();
			btn.x = center.x - btn.width / 2;
			btn.y = center.y - btn.height / 2;

			if (icons.members[idx] != null)
			{
				icons.members[idx].x = btn.x + btn.width + 20;
				icons.members[idx].y = btn.y + (btn.height / 2 - icons.members[idx].height / 2);
			}

			if (isHovered && lastHovered != btn)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				lastHovered = btn;
				bg.color = bgColors[idx % bgColors.length];
			}
			else if (!isHovered && lastHovered == btn)
			{
				lastHovered = null;
			}

			if (isHovered && FlxG.mouse.justPressed && buttonCallbacks.exists(btn))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				buttonCallbacks.get(btn)();
			}

			idx++;
		}

		if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) && !transitioning)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			startTransition(new MainMenuState());
		}
	}
}
