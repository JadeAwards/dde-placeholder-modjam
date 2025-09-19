package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class FindTheDevState extends MusicBeatState
{
	var targets:FlxGroup;
	var score:Int = 0;
	var round:Int = 1;
	var lives:Int = 3;
	var timer:Float = 20;

	var bg:FlxSprite;
	var poster:FlxSprite;

	var song:FlxSound;

	var scoreTxt:FlxText;
	var livesTxt:FlxText;
	var timerTxt:FlxText;
	var title:FlxText;
	var howTo:FlxText;
	var playTxt:FlxText;

	var wantedChar:String;
	var chars:Array<String> = [
		     "tanrake", "jade", "melonman",   "thebigleft",
		"realbradytgn", "adam",  "2arryy_", "milk_with_rice"
	];

	var gameActive:Bool = false;
	var introActive:Bool = true;

	override public function create():Void
	{
		super.create();
		initBackground();
		initPoster();

		scoreTxt = new FlxText(0, -5, 1280, "Score: 0", 24);
		scoreTxt.setFormat(Paths.font("upheavtt.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		add(scoreTxt);

		livesTxt = new FlxText(0, 30, 1280, "Lives: 3", 24);
		livesTxt.setFormat(Paths.font("upheavtt.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		livesTxt.borderSize = 2;
		add(livesTxt);

		timerTxt = new FlxText(0, 2, 1280, "Time: 20", 24);
		timerTxt.setFormat(Paths.font("upheavtt.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timerTxt.borderSize = 2;
		add(timerTxt);

		title = new FlxText(0, 150, 1280, "Find the Dev!", 64);
		title.setFormat(Paths.font("upheavtt.ttf"), 64, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.borderSize = 2;
		add(title);

		howTo = new FlxText(0, 280, 1280, "How to play:\nClick the WANTED person before the timer runs out!\nYou lose a life if you miss or time runs out.",
			28);
		howTo.setFormat(Paths.font("upheavtt.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		howTo.borderSize = 2;
		add(howTo);

		playTxt = new FlxText(0, 500, 1280, "Press ENTER to Play\nPress ESC to Quit", 32);
		playTxt.setFormat(Paths.font("upheavtt.ttf"), 32, FlxColor.LIME, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		playTxt.borderSize = 2;
		add(playTxt);

		FlxG.mouse.visible = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		handleIntroInput();
		handleGameInput(elapsed);
		updateUIText();
	}

	function initBackground():Void
	{
		bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.fromRGB(135, 206, 235));
		add(bg);
	}

	function initPoster():Void
	{
		poster = new FlxSprite();
		poster.antialiasing = false;
		poster.visible = false;
		add(poster);
	}

	function handleIntroInput():Void
	{
		if (!introActive)
			return;
		if (FlxG.keys.justPressed.ENTER)
			startGame();
		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MainMenuState());
	}

	function handleGameInput(elapsed:Float):Void
	{
		if (!gameActive)
			return;
		timer -= elapsed;
		if (timer <= 0)
		{
			lives--;
			if (lives <= 0)
				endGame();
			else
				fadeTransition(startRound);
		}
		if (FlxG.mouse.justPressed)
			checkHit();
	}

	function updateUIText():Void
	{
		timerTxt.text = "Time: " + Std.int(Math.ceil(timer));
		scoreTxt.text = "Score: " + score;
		livesTxt.text = "Lives: " + lives;
	}

	function startGame():Void
	{
		introActive = false;
		title.visible = false;
		howTo.visible = false;
		playTxt.visible = false;
		poster.visible = true;
		scoreTxt.visible = true;
		livesTxt.visible = true;
		timerTxt.visible = true;

		FlxG.sound.list.forEach(function(s) if (s != null)
			s.stop());
		song = new FlxSound();
		song.loadEmbedded(Paths.music("findTheDev"), true, true);
		song.play(true);
		FlxG.sound.list.add(song);

		startRound();
	}

	function startRound():Void
	{
		clearTargets();
		timer = 20;
		gameActive = true;
		round++;

		wantedChar = chars[Std.random(chars.length)];
		poster.loadGraphic(Paths.image("credits/wanted/wanted_" + wantedChar));
		poster.x = (FlxG.width - poster.width) / 2;
		poster.y = 35;

		var bgColor:Int = getBgColor(wantedChar);
		var roundBg = new FlxSprite().makeGraphic(1280, 720, bgColor);
		insert(0, roundBg);

		addTarget(wantedChar);
		for (i in 0...45)
			addTarget(getFakeChar());
	}

	function checkHit():Void
	{
		for (t in targets.members)
		{
			var spr:Target = cast t;
			if (spr != null && spr.alive && spr.overlapsPoint(FlxG.mouse.getWorldPosition()))
			{
				if (spr.charID == wantedChar)
				{
					score += 100;
					spr.kill();
					fadeTransition(startRound);
					return;
				}
				else
				{
					lives--;
					score -= 50;
					spr.kill();
					shakeLivesText();
					if (lives <= 0)
						endGame();
					return;
				}
			}
		}
	}

	function fadeTransition(callback:Void->Void):Void
	{
		gameActive = false;
		var overlay = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		overlay.alpha = 0;
		add(overlay);
		FlxTween.tween(overlay, {alpha: 0.7}, 0.3, {
			ease: FlxEase.quadIn,
			onComplete: function(_)
			{
				remove(overlay, true);
				callback();
			}
		});
	}

	function shakeLivesText():Void
	{
		var origX = livesTxt.x;
		livesTxt.color = FlxColor.RED;
		function shakeStep(step:Int):Void
		{
			switch (step)
			{
				case 0:
					FlxTween.tween(livesTxt, {x: origX - 10}, 0.05, {onComplete: function(_) shakeStep(1)});
				case 1:
					FlxTween.tween(livesTxt, {x: origX + 10}, 0.1, {onComplete: function(_) shakeStep(2)});
				case 2:
					FlxTween.tween(livesTxt, {x: origX}, 0.05, {onComplete: function(_) livesTxt.color = FlxColor.WHITE});
			}
		}
		shakeStep(0);
	}

	function endGame():Void
	{
		gameActive = false;
		if (song != null)
			song.stop();
		FlxG.sound.list.forEach(function(s) if (s != null)
			s.stop());
		var overlay = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		overlay.alpha = 0;
		add(overlay);
		FlxTween.tween(overlay, {alpha: 0.7}, 1.5, {ease: FlxEase.quadOut});

		var resultTxt = new FlxText(0, 300, 1280, "GAME OVER!\nFinal Score: " + score + "\nPress ENTER to Retry\nPress ESC to quit", 32);
		resultTxt.setFormat(Paths.font("upheavtt.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resultTxt.borderSize = 2;
		add(resultTxt);
	}

	function resetIntro():Void
	{
		score = 0;
		round = 1;
		lives = 3;
		timer = 20;
		clearTargets();
		poster.visible = false;
		scoreTxt.visible = false;
		livesTxt.visible = false;
		timerTxt.visible = false;
		title.visible = true;
		howTo.visible = true;
		playTxt.visible = true;
		introActive = true;
		if (song != null)
		{
			song.stop();
			FlxG.sound.list.remove(song);
			song = null;
		}
	}

	function clearTargets():Void
	{
		for (t in targets.members)
			remove(t, true);
		targets.clear();
	}

	function getBgColor(char:String):Int
	{
		switch (char)
		{
			case "jade":
				return 0xFFA5ED60;
			case "tanrake":
				return 0xFFDBE7FF;
			case "melonman", "thebigleft", "milk_with_rice":
				return FlxColor.WHITE;
			case "realbradytgn":
				return 0xFFAD1545;
			case "adam":
				return 0xFF883FA4;
			case "2arryy_":
				return 0xFF8293FF;
			default:
				return FlxColor.fromRGB(135, 206, 235);
		}
	}

	function getFakeChar():String
	{
		var c = chars[Std.random(chars.length)];
		while (c == wantedChar)
			c = chars[Std.random(chars.length)];
		return c;
	}

	function addTarget(char:String):Void
	{
		var pos = getSafeSpawn();
		var t = new Target(pos.x, pos.y, char, poster);
		targets.add(t);
		add(t);
	}

	function getSafeSpawn():{x:Float, y:Float}
	{
		var xPos:Float;
		var yPos:Float;
		do
		{
			xPos = Std.random(1100);
			yPos = Std.random(500);
		}
		while (inPosterBounds(xPos, yPos));
		return {x: xPos, y: yPos};
	}

	function inPosterBounds(xPos:Float, yPos:Float):Bool
	{
		var pad = 50;
		var px = poster.x - pad;
		var py = poster.y - pad;
		var pw = poster.width + pad * 2;
		var ph = poster.height + pad * 2;
		return xPos >= px && xPos <= px + pw && yPos >= py && yPos <= py + ph;
	}
}

class Target extends FlxSprite
{
	public var charID:String;
	public var xSpeed:Float;
	public var ySpeed:Float;
	public var poster:FlxSprite;

	public function new(xPos:Float, yPos:Float, id:String, posterRef:FlxSprite)
	{
		super(xPos, yPos);
		charID = id;
		poster = posterRef;
		loadGraphic(Paths.image("credits/wanted/" + id));
		xSpeed = FlxG.random.float(-200, 200);
		ySpeed = FlxG.random.float(-200, 200);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		x += xSpeed * elapsed;
		y += ySpeed * elapsed;

		if (x <= 0 || x + width >= FlxG.width)
			xSpeed *= -1;
		if (y <= 0 || y + height >= FlxG.height)
			ySpeed *= -1;

		if (overlaps(poster))
		{
			if (x + width / 2 < poster.x)
				x = poster.x - width;
			else if (x + width / 2 > poster.x + poster.width)
				x = poster.x + poster.width;
			if (y + height / 2 < poster.y)
				y = poster.y - height;
			else if (y + height / 2 > poster.y + poster.height)
				y = poster.y + poster.height;
			xSpeed *= -1;
			ySpeed *= -1;
		}
	}
}
