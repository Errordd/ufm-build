package backend;

/**
 * this class contains all the features of the mod that were previously coded in lua
 * now converted to be hardcoded directly into the engine.
 */
class Features{
    //LOADS ALL THE OTHER FEATURES.
    public var cmb:ComboThing; //allow access in playstate
    public function new(Inst:PlayState){
        cmb = new ComboThing(Inst); //init the combo thingy.
    }
}

/**
 * anglecamera.lua
 */
class AngleCamera { //TODO: re-write because it was stolen from pibby apocalypse smdh.

}

/**
 * script combo thing.lua
 */
class ComboThing {
    private var INSTANCE:PlayState;

    public var maxCombo:Int = 0;

    private var ComboTargetScale:Float = 1;
    private var MaxComboTargetScale:Float = 1;

    private var texts:Array<String> = ['Combo: 0', 'Max Combo: 0', 'Sicks!!: 0', 'Goods!: 0', 'Bads: 0', 'Shits: 0', 'Misses: 0'];
    private var Txt:Array<FlxText> = []; //0:combo, 1:maxCombo, 2:Sicks, 3:Goods, 4:Bads, 5:Shits, 6:Misses
    private var Y:Array<Int> = [
        610, //combo
        640, //MaxCombo
        320, //sicks
        350, //goods
        380, //bads
        410, //shits
        440, //misses
    ];
    private var X:Array<Int> = [ //kinda just duplicates the value but whateva
        -18, //combo
        -18, //MaxCombo
        -28, //sicks
        -28, //goods
        -28, //bads
        -28, //shits
        -28, //misses
    ];
    public var info:{
        combo:Int,
        sicks:Int,
        goods:Int,
        bads:Int,
        shits:Int,
        misses:Int
    };

    public function new(PS:PlayState){
        INSTANCE = PS; //passthrough
        //create all the ui elements n stuff.

        for(i in 0...texts.length){
            var txt:FlxText = new FlxText(X[i], Y[i], 200, texts[i], 20, true);
            txt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            txt.camera = PS.camHUD;
            Txt.push(txt);
            PS.add(txt);
        }

        Txt[1].color = 0xfff700; //maxcombo
        Txt[6].color = 0x36eaf7; //misses
    }

    public function upd(elapsed:Float){
        if(INSTANCE != null){
            info = {
                combo: INSTANCE.combo,
                sicks: INSTANCE.ratingsData[0].hits,
                goods: INSTANCE.ratingsData[1].hits,
                bads: INSTANCE.ratingsData[2].hits,
                shits: INSTANCE.ratingsData[3].hits,
                misses: INSTANCE.songMisses
            }; 

            if(info.combo > maxCombo)
                maxCombo = info.combo;

            Txt[0].text = 'Combo: ${info.combo}';
            Txt[1].text = 'Max Combo: $maxCombo';
            Txt[2].text = 'Sicks!!: ${info.sicks}';
            Txt[3].text = 'Goods!: ${info.goods}';
            Txt[4].text = 'Bads: ${info.bads}';
            Txt[5].text = 'Shits: ${info.shits}';

            if(info.misses > 0)
                Txt[6].text = 'Misses: ${info.misses}';
            else
                Txt[6].text = 'Misses: FC';


            //idk what these do but ok.


            if(info.misses > 0){
                Txt[6].color = FlxColor.fromString('#ff0000');
            }


            Txt[0].scale.x = FlxMath.lerp(ComboTargetScale, Txt[0].scale.x, Math.exp(-elapsed * 3.125 * INSTANCE.camZoomingDecay * INSTANCE.playbackRate)); //lerps instead of static tweens, much cooler, right?
            Txt[0].scale.y = FlxMath.lerp(ComboTargetScale, Txt[0].scale.y, Math.exp(-elapsed * 3.125 * INSTANCE.camZoomingDecay * INSTANCE.playbackRate));
            Txt[1].scale.x = FlxMath.lerp(MaxComboTargetScale, Txt[1].scale.x, Math.exp(-elapsed * 3.125 * INSTANCE.camZoomingDecay * INSTANCE.playbackRate));
            Txt[1].scale.y = FlxMath.lerp(MaxComboTargetScale, Txt[1].scale.y, Math.exp(-elapsed * 3.125 * INSTANCE.camZoomingDecay * INSTANCE.playbackRate));
        }
    }

    public function HIT(inf:{ combo:Int, sicks:Int, goods:Int, bads:Int, shits:Int, misses:Int}){
        ComboTargetScale = 1.03;
        if(maxCombo == inf.combo)
            MaxComboTargetScale = 1.03;
    }
}