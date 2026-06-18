package states;
import flixel.FlxG;
import flixel.FlxSprite;
import backend.Paths;
import states.TitleState;
class GoAwayState extends MusicBeatState
{
    public var jeffy:FlxSprite;
    var transitioning:Bool = false;
    override public function create()
    {
        super.create();
        jeffy = new FlxSprite();
        jeffy.loadGraphic(Paths.image('jeffyJumpscare'));
        jeffy.scrollFactor.set(0, 0);
        jeffy.scale.set(FlxG.width / jeffy.width, FlxG.height / jeffy.height);
        jeffy.updateHitbox();
        jeffy.x = 0;
        jeffy.y = 0;
        add(jeffy);
        if (FlxG.sound.music != null) {
            FlxG.sound.music.stop();
        }
        FlxG.sound.play(Paths.sound('jeffyJumpscare'), 1, false, null, true, function() {
            if (!transitioning) {
                transitioning = true;
                MusicBeatState.switchState(new TitleState());
            }
        });
    }
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}
