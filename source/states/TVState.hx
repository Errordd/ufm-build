package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets.FlxShader;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.filters.BlurFilter;
import openfl.filters.BitmapFilter;
import flixel.math.FlxMath;

class TVScreenShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header
        
        uniform float iTime;
        
        float noise(vec2 p) {
            vec2 ip = floor(p);
            vec2 u = fract(p);
            u = u * u * (3.0 - 2.0 * u);
            
            float res = mix(
                mix(sin(dot(ip, vec2(13.9898, 8.1376))),
                    sin(dot(ip + vec2(1.0, 0.0), vec2(13.9898, 8.1376))), u.x),
                mix(sin(dot(ip + vec2(0.0, 1.0), vec2(13.9898, 8.1376))),
                    sin(dot(ip + vec2(1.0, 1.0), vec2(13.9898, 8.1376))), u.x), u.y);
            return res * 0.5 + 0.5;
        }
        
        vec3 rgbSplit(sampler2D tex, vec2 uv, float amount) {
            float r = flixel_texture2D(tex, vec2(uv.x + amount, uv.y - amount * 0.3)).r;
            float g = flixel_texture2D(tex, uv).g;
            float b = flixel_texture2D(tex, vec2(uv.x - amount, uv.y + amount * 0.3)).b;
            return vec3(r, g, b);
        }
        
        vec3 phosphorMask(vec2 uv, vec3 col) {
            float distFromCenter = length(uv - 0.5) * 2.0;
            float scaleMultiplier = 1.0 + distFromCenter * 0.6;
            
            float maskX = fract(uv.x * 3.0 * openfl_TextureSize.x / 6.0 * scaleMultiplier);
            float maskY = fract(uv.y * openfl_TextureSize.y / 3.0 * scaleMultiplier);
            
            vec3 mask = vec3(0.0);
            
            if (maskX < 0.333)
                mask.r = 1.0;
            else if (maskX < 0.666)
                mask.g = 1.0;
            else
                mask.b = 1.0;
            
            float verticalMask = sin(maskY * 3.14159 * 2.0) * 0.5 + 0.5;
            mask *= mix(0.75, 1.0, verticalMask);
            
            float maskIntensity = mix(0.25, 0.45, smoothstep(0.0, 1.0, distFromCenter));
            
            return mix(col, col * mask, maskIntensity);
        }
        
        void main() {
            vec2 uv = openfl_TextureCoordv;
            
            vec2 finalUV = vec2(
                uv.x + (noise(vec2(iTime * 15.0, uv.y * 80.0)) * 0.0003 + noise(vec2(iTime * 1.0, uv.y * 25.0)) * 0.0005),
                uv.y
            );
            
            vec3 col = rgbSplit(bitmap, finalUV, 0.0045);
            vec4 color = vec4(col, flixel_texture2D(bitmap, finalUV).a);
            
            float scanlineIntensity = 0.07;  // Remove sin variation to prevent blinking
            float scanline = sin(finalUV.y * 950.0) * scanlineIntensity;
            color.rgb -= scanline;
            
            color.rgb = phosphorMask(finalUV, color.rgb);
            
            float staticNoise = noise(finalUV * 180.0 + iTime * 18.0) * 0.04 - 0.02;  // Reduced noise intensity
            color.rgb += staticNoise;
            
            vec4 bloomColor = flixel_texture2D(bitmap, finalUV);
            color.rgb += bloomColor.rgb * 0.18;
            
            color.rgb = (color.rgb - 0.5) * 1.25 + 0.5;
            
            float distortionY = sin(finalUV.y * 30.0 + iTime) * 0.0005; 
            color.rgb += noise(vec2(finalUV.x + distortionY, iTime * 6.0)) * 0.01 - 0.005; 
            
            gl_FragColor = color;
        }
    ')
    
    public function new()
    {
        super();
        this.iTime.value = [0.0];
    }
    
    public function update(elapsed:Float)
    {
        this.iTime.value[0] += elapsed * 0.5; 
    }
}

class TVState extends MusicBeatState
{
    private var codeText:FlxText;
    private var codeLines:Array<String>;
    private var currentLine:Int = 0;
    private var charIndex:Int = 0;
    private var baseTypingSpeed:Float = 0.02;
    private var lineDelay:Float = 0.5;
    private var isTyping:Bool = false;
    private var typingComplete:Bool = false;
    private var lineHeight:Float = 16;
    private var maxLines:Int = 20;
    private var displayStartLine:Int = 0;
    
    private var scanlines:Array<FlxSprite> = [];
    private var blackOverlay:FlxSprite;
    private var shutdownStarted:Bool = false;
    
    private var typingTimer:FlxTimer;
    private var performanceTimer:Float = 0;
    private var performanceChangeInterval:Float = 0.3;
    private var currentPerformanceMultiplier:Float = 1.0;
    
    private var stutterChance:Float = 0.15;        
    private var burstChance:Float = 0.25;        
    private var pauseChance:Float = 0.08;        
    private var pauseDuration:Float = 0;        
    private var longPauseChance:Float = 0.03;     
    private var processingMode:Bool = false;  
    private var processingTimer:Float = 0;        
    private var processingDuration:Float = 0;     
    private var charBurstCount:Int = 0;     
    private var maxBurstCount:Int = 0;

    private var wall:FlxSprite;
    private var window:FlxSprite;
    private var tv:FlxSprite;
    private var tvScreen:FlxSprite;
    private var desk:FlxSprite;
    private var wires:FlxSprite;
    private var plush:FlxSprite;
    private var poster:FlxSprite;
    private var mouse:FlxSprite;
    private var hand:FlxSprite;

    private var tvScreenShader:TVScreenShader;
    private var biosText:FlxText;

    private var cameraOriginalX:Float;
    private var cameraOriginalY:Float;
    private var cameraTargetX:Float;
    private var cameraTargetY:Float;
    private var cameraLerpAmount:Float = 0.06; 
    private var cameraMaxOffsetX:Float = 15;
    private var cameraMaxOffsetY:Float = 10;
    
    override function create()
    {
        super.create();
        
        persistentUpdate = true;
        persistentDraw = true;
        
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bg);

        wall = new FlxSprite(0, 0).loadGraphic(Paths.image('wall'));
        wall.setGraphicSize(FlxG.width + 50, Std.int(wall.height * 1.2));
        wall.updateHitbox();
        wall.screenCenter();
        add(wall);

        window = new FlxSprite(0, 0).loadGraphic(Paths.image('window'));
        window.setGraphicSize(Std.int(window.width * 0.8), Std.int(window.height * 0.8));
        window.updateHitbox();
        window.x = 20; 
        window.y = FlxG.height / 3 - window.height / 2;
        add(window);

        poster = new FlxSprite(0, 0).loadGraphic(Paths.image('poster'));
        poster.setGraphicSize(Std.int(poster.width * 0.8), Std.int(poster.height * 0.8));
        poster.updateHitbox();
        poster.x = FlxG.width - poster.width - 5; 
        poster.y = FlxG.height / 3 - poster.height / 2;
        add(poster);
        
        desk = new FlxSprite(0, 0).loadGraphic(Paths.image('desk'));
        desk.setGraphicSize(FlxG.width);
        desk.updateHitbox();
        desk.screenCenter(X);
        desk.y = FlxG.height - desk.height + 400;
        add(desk);

        wires = new FlxSprite(0, 0).loadGraphic(Paths.image('wires'));
        wires.setGraphicSize(Std.int(wires.width * 0.6), Std.int(wires.height * 0.6));
        wires.updateHitbox();
        wires.screenCenter(X);
        wires.y = desk.y - wires.height * 0.57;
        add(wires);

        tv = new FlxSprite(0, 0).loadGraphic(Paths.image('TV'));
        tv.setGraphicSize(Std.int(tv.width * 0.7), Std.int(tv.height * 0.7));
        tv.updateHitbox();
        tv.screenCenter(X);
        tv.y = FlxG.height * 0.65 - tv.height / 2;
        
        tvScreen = new FlxSprite(0, 0).loadGraphic(Paths.image('blackscreengoboom'));
        tvScreen.setGraphicSize(Std.int(tv.width * 1), Std.int(tv.height * 1));
        tvScreen.updateHitbox();
        tvScreen.x = tv.x + (tv.width - tvScreen.width) / 2 + 15;
        tvScreen.y = tv.y + (tv.height - tvScreen.height) / 2 + 10;
        
        tvScreenShader = new TVScreenShader();
        tvScreen.shader = tvScreenShader;

        add(tvScreen);

        plush = new FlxSprite(0, 0).loadGraphic(Paths.image('plushie'));
        plush.setGraphicSize(Std.int(plush.width * 0.8), Std.int(plush.height * 0.8));
        plush.updateHitbox();
        plush.x = tv.x - plush.width + 300;
        plush.y = desk.y - plush.height + 300;

        mouse = new FlxSprite(0, 0).loadGraphic(Paths.image('mouse'));
        mouse.setGraphicSize(Std.int(mouse.width * 0.6), Std.int(mouse.height * 0.6));
        mouse.updateHitbox();
        mouse.x = tv.x + tv.width * 0.86;
        mouse.y = desk.y - mouse.height + 400; 

        hand = new FlxSprite(0, 0).loadGraphic(Paths.image('hand'));
        hand.setGraphicSize(Std.int(hand.width * 0.6), Std.int(hand.height * 0.6));
        hand.updateHitbox();
        hand.x = tv.x + tv.width * 0.83;
        hand.y = desk.y - hand.height + 400; 
        
        biosText = new FlxText(tvScreen.x + 120, tvScreen.y + 160, tvScreen.width - 20, "", 10);
        biosText.setFormat("VCR OSD Mono", 10, FlxColor.LIME, LEFT);
        biosText.text = "############################################################\n" +
                        "############################################################\n" +
                        "###                                                      ###\n" +
                        "###                    MS-DOS 2.1                        ###\n" +
                        "###                                                      ###\n" +
                        "###          PRESS [0x0D] TO EXECUTE PROGRAM             ###\n" +
                        "###                                                      ###\n" +
                        "############################################################\n" +
                        "############################################################\n" +
                        "C:\\>";
        add(biosText);
        add(tv);
        add(plush);
        add(mouse);
        add(hand);
        
        var scanlineCount = 40;
        var scanlineHeight = 1;
        var scanlineSpacing = Math.floor(FlxG.height / scanlineCount);
        
        for (i in 0...scanlineCount) {
            var line = new FlxSprite(0, i * scanlineSpacing).makeGraphic(FlxG.width, scanlineHeight, FlxColor.fromRGB(150, 150, 150, 100));
            line.alpha = 0;
            scanlines.push(line);
            add(line);
        }
        
        blackOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackOverlay.alpha = 0;
        add(blackOverlay);
        
        typingComplete = true;

        cameraOriginalX = FlxG.camera.scroll.x;
        cameraOriginalY = FlxG.camera.scroll.y;
        cameraTargetX = cameraOriginalX;
        cameraTargetY = cameraOriginalY;
        
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("BIOS Boot Sequence", null);
        #end
    }
    
    private function startShutdownSequence():Void
    {
        if (shutdownStarted) return;
        shutdownStarted = true;
        
        new FlxTimer().start(1.0, function(_)
        {
            FlxG.sound.play(Paths.sound('tv_off'), 0.7);
            
            for (i in 0...scanlines.length)
            {
                var line = scanlines[i];
                
                FlxTween.tween(line, {alpha: 0.7}, 0.3, {
                    startDelay: i * 0.01,
                    ease: FlxEase.sineInOut
                });
                
                if (FlxG.random.bool(30)) {
                    FlxTween.tween(line, {x: FlxG.random.float(-5, 5)}, 0.2, {
                        type: FlxTweenType.PINGPONG,
                        ease: FlxEase.sineInOut
                    });
                }
            }
            
            new FlxTimer().start(0.8, function(_)
            {
                for (i in 0...scanlines.length)
                {
                    var line = scanlines[i];
                    var targetY = FlxG.height / 2;
                    var delay = Math.abs((line.y - targetY) / FlxG.height) * 0.3;
                    
                    FlxTween.tween(line, {
                        y: targetY,
                        alpha: i == Math.floor(scanlines.length / 2) ? 1.0 : 0.0
                    }, 0.5, {
                        startDelay: delay,
                        ease: FlxEase.quadInOut
                    });
                }
                
                FlxTween.tween(blackOverlay, {alpha: 1}, 0.5, {
                    startDelay: 0.5,
                    ease: FlxEase.quadIn,
                    onComplete: function(_)
                    {
                        new FlxTimer().start(3.0, function(_)
                        {
                            MusicBeatState.switchState(new ComputerState());
                        });
                    }
                });
                
                FlxTween.tween(biosText, {alpha: 0}, 0.5, {
                    startDelay: 0.3,
                    ease: FlxEase.quadIn
                });
            });
        }
    );
    }
    
    override function update(elapsed:Float)
    {
        tvScreenShader.update(elapsed);

        var mouseXPercent = FlxG.mouse.screenX / FlxG.width;
        var mouseYPercent = FlxG.mouse.screenY / FlxG.height;
    
        cameraTargetX = cameraOriginalX + (mouseXPercent - 0.5) * cameraMaxOffsetX * 2;
        cameraTargetY = cameraOriginalY + (mouseYPercent - 0.5) * cameraMaxOffsetY * 2;
    
        FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, cameraTargetX, cameraLerpAmount);
        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, cameraTargetY, cameraLerpAmount);

        if (controls.ACCEPT && typingComplete && !shutdownStarted)
        {
            startShutdownSequence();
        }
        
        super.update(elapsed);
    }
    
    override function destroy()
    {
        if (typingTimer != null) typingTimer.cancel();
        FlxG.camera.setFilters([]);
        super.destroy();
    }
}
