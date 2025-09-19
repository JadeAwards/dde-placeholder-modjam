package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.MusicBeatState;
import states.MainMenuState;

class CreditsState extends MusicBeatState
{
	var images:Array<FlxSprite> = [];
	var labels:Array<FlxText> = [];
	var velocities:Array<{x:Float, y:Float}> = [];

	var entries:Array<
		{
			path:String,
			name:String,
			credit:String,
			socials:Array<String>,
			description:String
		}>;

	var popupBG:FlxSprite;
	var popupBox:FlxSprite;
	var popupTitle:FlxText;
	var popupText:FlxText;
	var popupDesc:FlxText;
	var popupSocials:Array<FlxText> = [];
	var closeButton:FlxText;
	var popupVisible:Bool = false;

	override public function create():Void
	{
		super.create();

		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.mouse.visible = true;

		entries = [
			{
				path: "credits/2arryy_",
				name: "2arryy_",
				credit: "Composer",
				socials: ["https://www.youtube.com/@2aRRyy"],
				description: "hello i'm 2arry from friday night funkin' and i made music for ts mod, and uhh bf sprites in placeholder"
			},
			{
				path: "credits/jade",
				name: "JadeAwards",
				credit: "Programmer, Artist",
				socials: ["https://www.youtube.com/@jadeawards", "https://x.com/jadeaward_s"],
				description: "Hello everyone! Hoping you guys liked the mod and had fun playing it. I'm glad to be a part of this team with my wonderful friends and have fun doing I know best for this mod! (*cough, programming, cough*)\n\n\nThank you for playing!"
			},
			{
				path: "credits/melonman",
				name: "MelonMan",
				credit: "Composer",
				socials: ["https://www.youtube.com/@RealMelonMan", "https://x.com/RealMelonMan"],
				description: "I'm MelonMan! If anyone is reading this, necesarry got kinda weird due to time contraints, look foward to a more polished version in future updates!"
			},
			{
				path: "credits/realbradytgn",
				name: "RealBradyTGN",
				credit: "Composer",
				socials: [
					"https://www.youtube.com/@RealBradyTGN",
					"https://steamcommunity.com/profiles/76561199206311997/"
				],
				description: "Yeah so I basically made the majority of the soundtrack here. Pretty cool, right? I do hope you enjoy the songs, I put my soul into these songs, and thank you MelonMan for the base for Necessary, I had no fuckin idea what I was doing. yeah please make videos on this I like attention"
			},
			{
				path: "credits/tanrake",
				name: "tanrake",
				credit: "Artist",
				socials: ["https://www.youtube.com/@tangerinelmao", "https://www.tiktok.com/@tanrakev2"],
				description: "yo i did most of the art! it was stressful but rlly fun to make. thank you left for giving me the opportunity to join the mod! tchau :3"
			},
			{
				path: "credits/adam",
				name: "adamusique",
				credit: "Artist, Charter",
				socials: [
					"https://www.youtube.com/@adamusiqueuuh",
					"https://steamcommunity.com/id/Adamusique/"
				],
				description: "Sup guys its me adam\n\nI do art\n\nAnd i love source engine\n\nj'aime la merde"
			},
			{
				path: "credits/thebigleft",
				name: "TheBigLeft",
				credit: "Director, Artist",
				socials: ["https://x.com/ReatlL"],
				description: "Buuuuurps\n\nyea im the director and main artist or something ehhh\n\nim the true villain of this game HAHAHAHAHAHAHAHAHAHA\n\ncollect my pages"
			},
			{
				path: "credits/milk_with_rice",
				name: "Milk_With_Rice",
				credit: "Guest Composer",
				socials: ["https://www.youtube.com/@MilkWithRice"],
				description: "the residencial guy"
			}
		];

		for (entry in entries)
		{
			var sprite = new FlxSprite();
			sprite.loadGraphic(Paths.image(entry.path));
			sprite.x = FlxG.random.float(0, FlxG.width - sprite.width);
			sprite.y = FlxG.random.float(0, FlxG.height - sprite.height);
			add(sprite);
			images.push(sprite);

			var label = new FlxText(0, 0, sprite.width, entry.name, 12);
			label.setFormat(Paths.font('upheavtt.ttf'), 12, FlxColor.WHITE, "center");
			label.x = sprite.x;
			label.y = sprite.y + sprite.height + 2;
			add(label);
			labels.push(label);

			velocities.push({
				x: FlxG.random.float(-200, 200) / 60,
				y: FlxG.random.float(-200, 200) / 60
			});
		}

		popupBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		popupBG.alpha = 0.6;
		popupBG.visible = false;
		add(popupBG);

		popupBox = new FlxSprite(Std.int(FlxG.width / 6),
			Std.int(FlxG.height / 6)).makeGraphic(Std.int(FlxG.width * 2 / 3), Std.int(FlxG.height * 2 / 3), FlxColor.GRAY);
		popupBox.visible = false;
		popupBox.alpha = 0.7;
		add(popupBox);

		popupTitle = new FlxText(popupBox.x, popupBox.y + 20, popupBox.width, "", 24);
		popupTitle.setFormat(Paths.font('upheavtt.ttf'), 24, FlxColor.YELLOW, "center");
		popupTitle.visible = false;
		add(popupTitle);

		popupText = new FlxText(popupBox.x + 20, popupBox.y + 70, popupBox.width - 40, "", 16);
		popupText.setFormat(Paths.font('upheavtt.ttf'), 16, FlxColor.WHITE, "center");
		popupText.visible = false;
		add(popupText);

		popupDesc = new FlxText(popupBox.x + 20, popupBox.y + 110, popupBox.width - 40, "", 16);
		popupDesc.setFormat(Paths.font('upheavtt.ttf'), 16, FlxColor.WHITE, "center");
		popupDesc.visible = false;
		add(popupDesc);

		closeButton = new FlxText(0, 0, 40, "X", 20);
		closeButton.setFormat(Paths.font('upheavtt.ttf'), 20, FlxColor.WHITE, "center");
		closeButton.color = FlxColor.RED;
		closeButton.visible = false;
		add(closeButton);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (popupVisible)
				hidePopup();
			else
				MusicBeatState.switchState(new MainMenuState());
		}

		if (!popupVisible)
		{
			for (i in 0...images.length)
			{
				var sprite = images[i];
				var label = labels[i];
				var vel = velocities[i];

				sprite.x += vel.x;
				sprite.y += vel.y;
				label.x = sprite.x;
				label.y = sprite.y + sprite.height + 2;

				if (sprite.x < 0 || sprite.x + sprite.width > FlxG.width)
				{
					vel.x *= -1;
					sprite.x = Math.max(0, Math.min(FlxG.width - sprite.width, sprite.x));
				}
				if (sprite.y < 0 || sprite.y + sprite.height > FlxG.height)
				{
					vel.y *= -1;
					sprite.y = Math.max(0, Math.min(FlxG.height - sprite.height, sprite.y));
				}

				if (FlxG.mouse.overlaps(sprite) || FlxG.mouse.overlaps(label))
					sprite.color = FlxColor.GRAY;
				else
					sprite.color = FlxColor.WHITE;

				if (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(sprite) || FlxG.mouse.overlaps(label)))
				{
					showPopup(entries[i]);
				}
			}
		}
		else
		{
			for (s in popupSocials)
			{
				if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(s))
					FlxG.openURL(s.text);
			}

			if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(closeButton))
				hidePopup();
		}
	}

	function showPopup(entry:
		{
			path:String,
			name:String,
			credit:String,
			socials:Array<String>,
			description:String
		}):Void
	{
		popupTitle.text = entry.name;
		popupText.text = entry.credit;
		popupDesc.text = entry.description;

		for (s in popupSocials)
			remove(s);
		popupSocials = [];

		var startY = popupBox.y + popupBox.height - 80;
		for (i in 0...entry.socials.length)
		{
			var social = new FlxText(popupBox.x + 20, startY + i * 22, popupBox.width - 40, entry.socials[i], 16);
			social.setFormat(Paths.font('upheavtt.ttf'), 16, FlxColor.CYAN, "center");
			add(social);
			popupSocials.push(social);
		}

		popupBG.visible = true;
		popupBox.visible = true;
		popupTitle.visible = true;
		popupText.visible = true;
		popupDesc.visible = true;
		for (s in popupSocials)
			s.visible = true;

		closeButton.x = popupBox.x + popupBox.width - closeButton.width - 5;
		closeButton.y = popupBox.y + 5;
		closeButton.visible = true;

		popupBox.scale.set(0, 0);
		FlxTween.tween(popupBox.scale, {x: 1, y: 1}, 0.6, {ease: FlxEase.elasticOut});

		popupVisible = true;
	}

	function hidePopup():Void
	{
		popupBG.visible = false;
		popupBox.visible = false;
		popupTitle.visible = false;
		popupText.visible = false;
		popupDesc.visible = false;
		for (s in popupSocials)
			s.visible = false;
		closeButton.visible = false;
		popupVisible = false;
	}
}
