package objects;

class MainMenuFloaties extends FlxSprite
{
	public var framesDude:Int = 0;
	public function new(x:Float, y:Float)
	{
		super(x,y);
		antialiasing = ClientPrefs.data.antialiasing;
	}
	override function update(elapsed:Float)
	{
        super.update(elapsed);
        framesDude += 1;
        this.y += (Math.cos(framesDude*10)*5) * elapsed;
	}
}