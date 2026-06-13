#if android
package mobile.states;

import backend.ClientPrefs;
import backend.Language;
import backend.Mods;
import backend.ui.PsychUIButton;
import mobile.backend.StorageUtil;
import states.TitleState;

class AndroidPermissionsState extends MusicBeatState
{
	var statusText:FlxText;
	var subtitleText:FlxText;

	override function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		var bg = new FlxSprite().makeGraphic(1, 1, 0xFF151515);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		var title = new Alphabet(0, 40, 'ANDROID TOOLS', true);
		title.screenCenter(X);
		add(title);

		subtitleText = new FlxText(40, 150, FlxG.width - 80, 'Aquí revisas permisos y recargas el alphabet sin salir a pelearte con el sistema.', 24);
		subtitleText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
		subtitleText.scrollFactor.set();
		add(subtitleText);

		statusText = new FlxText(40, 250, FlxG.width - 80, '', 22);
		statusText.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.WHITE, LEFT);
		statusText.scrollFactor.set();
		add(statusText);

		var requestButton = new PsychUIButton(60, FlxG.height - 180, 'REQUEST PERMS', function()
		{
			StorageUtil.requestPermissions();
			refreshStatus();
		}, 220, 48);
		add(requestButton);

		var reloadAlphabetButton = new PsychUIButton(60, FlxG.height - 120, 'RELOAD ALPHABET', function()
		{
			Language.reloadPhrases();
			CoolUtil.showPopUp('Alphabet recargado, papá. Si algo estaba cacheado raro, ya se puso al día.', 'Alphabet');
			refreshStatus();
		}, 220, 48);
		add(reloadAlphabetButton);

		var backButton = new PsychUIButton(60, FlxG.height - 60, 'BACK', goBack, 140, 40);
		add(backButton);

		refreshStatus();
		addTouchPad('NONE', 'A_B');
		addTouchPadCamera();
	}

	function refreshStatus():Void
	{
		statusText.text = 'Storage mode: ${ClientPrefs.data.storageType}\n' + StorageUtil.getPermissionStatus();
		statusText.screenCenter(X);
	}

	function goBack():Void
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
	}

	override function update(elapsed:Float):Void
	{
		if (controls.BACK #if android || FlxG.android.justReleased.BACK #end)
		{
			goBack();
			return;
		}

		super.update(elapsed);
	}
}
#else
package mobile.states;

class AndroidPermissionsState extends MusicBeatState {}
#end
