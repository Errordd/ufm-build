package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class StereoWave extends FlxSprite
{
    public var waveform:FlxWaveform;
    public var sprTracker:FlxSprite;
    
    public var waveformColor:FlxColor = 0xFF4577BE;
    public var waveformRMSColor:FlxColor = 0xFF68C3FF;
    public var waveformBarSize:Int = 4;
    public var waveformBarPadding:Int = 2;
    
    private var targetSound:FlxSound;
    
    public function new(x:Float = 0, y:Float = 0, width:Int = 500, height:Int = 200, ?sound:FlxSound)
    {
        super(x, y);
        
        targetSound = sound != null ? sound : FlxG.sound.music;
        
        waveform = new FlxWaveform(0, 0, width, height);
        
        setupWaveform();
        
        scrollFactor.set();
    }
    
    private function setupWaveform():Void
    {
        if (targetSound != null)
        {
            waveform.loadDataFromFlxSound(targetSound);
            
            waveform.waveformDuration = 2000; 
            
            waveform.waveformDrawMode = COMBINED;
            
            waveform.waveformColor = waveformColor;
            waveform.waveformBgColor = 0x00000000;
            waveform.waveformRMSColor = waveformRMSColor;
            waveform.waveformDrawRMS = true;
            waveform.waveformDrawBaseline = true;
            waveform.waveformBarSize = waveformBarSize;
            waveform.waveformBarPadding = waveformBarPadding;
        }
    }
    
    public function changeSound(sound:FlxSound):Void
    {
        if (sound != null)
        {
            targetSound = sound;
            setupWaveform();
        }
    }
    
    public function updateWaveformStyle(
        ?color:FlxColor,
        ?rmsColor:FlxColor,
        ?barSize:Int,
        ?barPadding:Int
    ):Void {
        if (color != null) waveform.waveformColor = color;
        if (rmsColor != null) waveform.waveformRMSColor = rmsColor;
        if (barSize != null) waveform.waveformBarSize = barSize;
        if (barPadding != null) waveform.waveformBarPadding = barPadding;
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (targetSound != null && targetSound.playing)
        {
            waveform.waveformTime = targetSound.time;
        }
        
        if (sprTracker != null)
        {
            setPosition(sprTracker.x, sprTracker.y);
        }
    }
    
    override function draw()
    {
        if (waveform != null)
        {
            waveform.x = x;
            waveform.y = y;
            waveform.draw();
        }
        
        super.draw();
    }
}
