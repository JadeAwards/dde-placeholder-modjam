package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import options.OptionsState;
import states.editors.MasterEditorMenu;

class MainMenuState extends MusicBeatSubstate
{
	public static var psychEngineVersion:String = "1.0.4";

	var buttons:FlxTypedGroup<FlxSprite>;
	var buttonScale:Float = 1.92;
	var hoverScaleFactor:Float = 1.1;
	var hoverScale:Float;
	var buttonCallbacks:Map<FlxSprite, Void->Void> = new Map();
	var blackTransition:FlxSprite;
	var transitioning:Bool = false;

	var glombo:FlxSprite;
	var originalScale:FlxPoint;

	var stretchSound:FlxSound = null;

	var dragging:Bool = false;
	var dragStart:FlxPoint = null;
	var lastHovered:FlxSprite = null;

	override function create()
	{
		super.create();

		hoverScale = buttonScale * hoverScaleFactor;
		FlxG.mouse.visible = true;

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.antialiasing = false;
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFFFDE871;
		add(bg);

		glombo = new FlxSprite(FlxG.width - 650, FlxG.height / 2 - 525).loadGraphic(Paths.image("menuButtons/glombo"));
		glombo.antialiasing = false;
		glombo.origin.set(glombo.width / 2, glombo.height / 2);
		glombo.x += glombo.origin.x;
		glombo.y += glombo.origin.y;
		add(glombo);
		originalScale = new FlxPoint(glombo.scale.x, glombo.scale.y);

		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

		var atlas = Paths.getSparrowAtlas("menuButtons/menuButtons");
		var buttonX:Float = 25;
		var buttonYStart:Float = 5;
		var buttonSpacing:Float = 180;

		addButton(atlas, "play", buttonX, buttonYStart + 0 * buttonSpacing, FreeplayState);
		var optionsBtn = makeButton(atlas, "confi", buttonX, buttonYStart + 1 * buttonSpacing, function()
		{
			startTransition(new OptionsState());
			OptionsState.onPlayState = false;
			if (PlayState.SONG != null)
			{
				PlayState.SONG.arrowSkin = null;
				PlayState.SONG.splashSkin = null;
				PlayState.stageUI = "normal";
			}
		});
		addButton(atlas, "creds", buttonX, buttonYStart + 2 * buttonSpacing, CreditsState);
		var exitBtn = makeButton(atlas, "nah", buttonX, buttonYStart + 3 * buttonSpacing, function()
		{
			Sys.exit(0);
		});
		buttons.add(optionsBtn);
		buttons.add(exitBtn);

		addVersionText(12, FlxG.height - 44, "Psych Engine v" + psychEngineVersion);
		addVersionText(12, FlxG.height - 24, "DDE: Placeholder (" + Application.current.meta.get("version") + ")");

		blackTransition = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackTransition.alpha = 1;
		add(blackTransition);

		FlxTween.tween(blackTransition, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});
	}

	function addVersionText(x:Float, y:Float, text:String):Void
	{
		var t:FlxText = new FlxText(x, y, 0, text, 12);
		t.scrollFactor.set();
		t.setFormat(Paths.font("upheavtt.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(t);
	}

	function addButton(atlas:FlxAtlasFrames, frameName:String, x:Float, y:Float, stateClass:Class<FlxState>):Void
	{
		var btn = makeButton(atlas, frameName, x, y, function()
		{
			startTransition(Type.createInstance(stateClass, []));
		});
		buttons.add(btn);
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
		FlxTween.tween(blackTransition, {alpha: 1}, 0.5, {ease: FlxEase.quadIn, onComplete: function(_) FlxG.switchState(nextState)});
	}

	override function update(elapsed:Float)
	{
		#if desktop
		if (controls.justPressed('debug_1'))
		{
			FlxG.mouse.visible = false;
			startTransition(new MasterEditorMenu());
		}
		#end

		super.update(elapsed);

		var mousePos = FlxG.mouse.getScreenPosition();

		if (FlxG.mouse.justPressed && glombo.overlapsPoint(mousePos, true))
		{
			dragging = true;
			dragStart = new FlxPoint(mousePos.x, mousePos.y);
			stretchSound = FlxG.sound.play(Paths.sound('stretch'), 1, true);
		}

		if (FlxG.mouse.justReleased && dragging)
		{
			dragging = false;
			dragStart = null;

			if (stretchSound != null)
			{
				stretchSound.stop();
				stretchSound = null;
			}

			FlxG.sound.play(Paths.sound('wobble'));
			FlxTween.tween(glombo.scale, {x: originalScale.x, y: originalScale.y}, 1, {ease: FlxEase.elasticOut});
		}

		if (dragging && dragStart != null)
		{
			var deltaX = (mousePos.x - dragStart.x) * 0.01;
			var deltaY = (mousePos.y - dragStart.y) * 0.01;
			glombo.scale.x = Math.max(0.1, originalScale.x + deltaX);
			glombo.scale.y = Math.max(0.1, originalScale.y + deltaY);
		}

		for (btn in buttons)
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

			if (isHovered && lastHovered != btn)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				lastHovered = btn;
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
		}

		if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) && !transitioning)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			startTransition(new TitleState());
		}
	}
}
