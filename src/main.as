package xmlslideshow
{
import flash.display.*;
import flash.geom.*;
import flash.filters.*;
import fl.transitions.easing.*;
import com.nikos.utils.*;
import com.nikos.mytransitions.*;
//import com.nikos.mytransitions.fp10.*;
import com.greensock.TweenMax;
import com.greensock.loading.*;
import com.greensock.events.*;
import flash.text.TextFieldAutoSize;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.*;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.navigateToURL;;
import flash.utils.Timer;

public class main extends Sprite
{
	private var sw:int,sh:int;
	private var easing:Array=[];
	private var transitions:Array=[];
	private var parameters:Array=[];
	private var randomTransitions:Array=[];
	private var fx:Transition=null;
	private var fxparams:Object={};
	private var container:Sprite;
	private var imgs:Array=[];
	private var sharedimgs:Array=[];
	private var currentimg:int=-1;
	private var previmg:int=-1;
	private var timer:Timer=null;
	private var holder:Sprite;
	private var captionholder:Sprite;
	private var captiontext:TextField;
	private var txtFormat:TextFormat;
	private var controls:Sprite;
	private var enableControls:Boolean=false;
	private var randomOrder:Boolean=false;
	private var delay:Number=5.0;
	private var duration:Number=2.0;
	private var easingf:Function=None.easeNone;
	private var transitionf:String="random";
	private var thumbsize:int;
	private var thumbs:Sprite;
	private var thumbsa:Array=[];
	private var thumbs_move:Boolean=false;
	private var showControls:Boolean=true;
	private var gf:GlowFilter;
	private var ind:Array=[];
	private var marg:int=5;
	private var controls2:Sprite;
	private var paused:Boolean=false;
	
	// xml and loader vars
	private var xml:XML=null;
	private var list:XMLList=null;
	private var loader:URLLoader;
	private var myloader:ImageLoader=null;
	private var xml_len:int=0;
	private var xmlload:Boolean=false;
	private var imgload:Boolean=false;
	private var imgexists:Boolean=false;
	private var initlater:Boolean=false;
	
	public function main()
	{
		super();
		if (stage)
			init();
		else
		{
		 initlater=true;
		 addEventListener(Event.ADDED_TO_STAGE,init);
		}
	}
	
	private function init(e:Event=null):void
	{
		if (initlater)
		{
			removeEventListener(Event.ADDED_TO_STAGE,init);
			initlater=false;
		}
		// no scale to fit automatically in code
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		this.stage.align=StageAlign.TOP_LEFT;
		sw=this.stage.stageWidth;
		sh=this.stage.stageHeight;
		
		loading.x=0.5*sw;
		loading.y=0.5*sh;
		//loading.bar.scaleX=0;
		loading.percent.text="0%";
		loading.message.text="";
		
		prevbt.visible=false;
		nextbt.visible=false;
		playbt.visible=false;
		pausebt.visible=false;
		
		// random transitions
		randomTransitions.push({transition:"Blur", easing:None.easeNone, duration:2});
		randomTransitions.push({transition:"FlipPage3D", easing:Strong.easeOut, duration:2, mode:"bend"});
		randomTransitions.push({transition:"FlipPage3D", easing:Strong.easeOut, duration:2, mode:"twist"});
		randomTransitions.push({transition:"Shuffle", easing:Strong.easeOut, duration:2, mode:"left"});
		randomTransitions.push({transition:"Shuffle", easing:Regular.easeOut, duration:2, mode:"right"});
		randomTransitions.push({transition:"Fold", easing:Regular.easeOut, duration:2, mode:"left"});
		randomTransitions.push({transition:"Fold", easing:Regular.easeOut, duration:2, mode:"right"});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"rotate", ordering:"up-down", overlap:0.9});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"scale", ordering:"checkerboard", overlap:0});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"random-move", ordering:"random", overlap:0.95});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"random-move", ordering:"checkerboard", overlap:0.5});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"random-move", ordering:"rows", overlap:0.95});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"random-move", ordering:"columns", overlap:0.95});
		randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"random-move", ordering:"up-down", overlap:0.95});
		//randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"center-move", ordering:"checkerboard", overlap:0.5});
		//randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"center-move", ordering:"rows", overlap:0.9});
		//randomTransitions.push({transition:"JigsawPuzzle", easing:Regular.easeOut, duration:2, mode:"center-move", ordering:"diagonal-top-left", overlap:0.9});
		randomTransitions.push({transition:"Masks", easing:None.easeOut, duration:2});
		randomTransitions.push({transition:"Dissolve", easing:None.easeNone, duration:2});
		randomTransitions.push({transition:"Blinds", easing:Strong.easeOut, duration:2, ordering:"rows", mode:"center", columns:8, rows:8,overlap:0.95});
		randomTransitions.push({transition:"Blinds", easing:Strong.easeOut, duration:2, ordering:"rows-reverse", mode:"center", columns:8, rows:8,overlap:0.95});
		randomTransitions.push({transition:"Blinds", easing:Regular.easeOut, duration:2, ordering:"checkerboard", mode:"left", columns:8, rows:8,overlap:0});
		randomTransitions.push({transition:"Blinds", easing:Regular.easeInOut, duration:2, ordering:"random", mode:"left", columns:8, rows:1,overlap:0.95});
		randomTransitions.push({transition:"Blinds", easing:Regular.easeInOut, duration:2, ordering:"random", mode:"top", columns:1, rows:8,overlap:0.95});
		randomTransitions.push({transition:"Blinds", easing:Regular.easeInOut, duration:2, ordering:"columns-first", mode:"center", columns:8, rows:8,overlap:1});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"spiral-top-left", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"left-right", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"up-down", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"diagonal-top-left", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"spiral-bottom-left-reverse", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"left-right-reverse", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FadeTiles", easing:None.easeInOut, duration:2, ordering:"random", columns:6, rows:6,overlap:0.95});
		randomTransitions.push({transition:"FlipTiles", easing:Bounce.easeOut, duration:2, ordering:"random", columns:6, rows:6,overlap:0.95, spin:"horizontal"});
		randomTransitions.push({transition:"FlipTiles", easing:Bounce.easeOut, duration:2, ordering:"spiral-top-right-reverse", columns:6, rows:6,overlap:0.95, spin:"horizontal"});
		randomTransitions.push({transition:"FlipTiles", easing:Bounce.easeOut, duration:2, ordering:"spiral-bottom-right", columns:6, rows:6,overlap:0.95, spin:"vertical"});
		randomTransitions.push({transition:"FlipTiles", easing:Regular.easeOut, duration:2, ordering:"left-right", columns:6, rows:6,overlap:0.95, spin:"horizontal"});
		randomTransitions.push({transition:"FlipTiles", easing:Bounce.easeOut, duration:2, ordering:"up-down-reverse", columns:6, rows:6,overlap:0.92, spin:"horizontal"});
		randomTransitions.push({transition:"FlipTiles", easing:Bounce.easeOut, duration:2, ordering:"diagonal-bottom-right", columns:8, rows:8,overlap:0.92, spin:"horizontal"});
		randomTransitions.push({transition:"FlipPage", easing:Strong.easeOut, duration:2, mode:"diagonal-top-left-reverse"});
		randomTransitions.push({transition:"FlipPage", easing:Strong.easeOut, duration:2, mode:"diagonal-top-left"});
		randomTransitions.push({transition:"FlipPage", easing:Strong.easeOut, duration:2, mode:"horizontal-top-left-reverse"});
		randomTransitions.push({transition:"FlipPage", easing:Strong.easeOut, duration:2, mode:"horizontal-top-left"});
		randomTransitions.push({transition:"Slices", easing:Back.easeOut, duration:2, type:"in", overlap:0.92, alternate:true, area:150, angle:45, ordering:"random"});
		randomTransitions.push({transition:"Slices", easing:Back.easeOut, duration:2, type:"in", overlap:0.92, alternate:false, area:150, angle:45, ordering:"random"});
		randomTransitions.push({transition:"Slices", easing:Back.easeOut, duration:2, type:"in", overlap:0.92, alternate:true, area:100, angle:0, ordering:"random"});
		randomTransitions.push({transition:"Slices", easing:Back.easeOut, duration:2, type:"in", overlap:0.92, alternate:true, area:100, angle:90, ordering:"random"});
		randomTransitions.push({transition:"Slices", easing:Back.easeIn, duration:2, type:"out", overlap:0.92, alternate:true, area:150, angle:45, ordering:"random"});
		randomTransitions.push({transition:"GradientMasks", easing:Back.easeOut, duration:2, slices:4, overlap:0.9, alternate:true, mode:"vertical",  ordering:"random"});
		randomTransitions.push({transition:"GradientMasks", easing:Back.easeOut, duration:2, slices:4, overlap:0.9, alternate:true, mode:"horizontal",  ordering:"random"});
		randomTransitions.push({transition:"GradientMasks", easing:Back.easeOut, duration:2, slices:4, overlap:0.9, alternate:false, mode:"vertical",  ordering:"random"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:1, overlap:0.9, slicing:"horizontal", direction:"left", ordering:"columns-first"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:1, overlap:0.9, slicing:"horizontal", direction:"right", ordering:"columns-first"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:1, overlap:0.9, slicing:"vertical", direction:"up", ordering:"columns-first"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:1, overlap:0.9, slicing:"vertical", direction:"down", ordering:"columns-first"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:3, overlap:0.9, slicing:"horizontal", direction:"left", ordering:"columns-first"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:3, overlap:0.9, slicing:"vertical", direction:"down", ordering:"columns-first"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:3, overlap:0.9, slicing:"vertical", direction:"up", ordering:"random"});
		randomTransitions.push({transition:"Cubes", easing:Strong.easeOut, duration:2, slices:3, overlap:0.9, slicing:"horizontal", direction:"right", ordering:"random"});
		randomTransitions.push({transition:"ScaleTiles", easing:Regular.easeOut, duration:2, ordering:"left-right", reverse:true, columns:6, rows:6, overlap:0.97});
		randomTransitions.push({transition:"ScaleTiles", easing:Strong.easeOut, duration:2, ordering:"columns-first", reverse:true, rotate:true, columns:6, rows:6, overlap:1});
		randomTransitions.push({transition:"ScaleTiles", easing:Regular.easeOut, duration:2, ordering:"up-down-reverse", reverse:true, columns:6, rows:6, overlap:0.97});
		randomTransitions.push({transition:"ScaleTiles", easing:Strong.easeOut, duration:2, ordering:"columns-first", rotate:true, columns:6, rows:6, overlap:1});
		randomTransitions.push({transition:"GradientSweep", easing:Strong.easeOut, duration:2, mode:"left"});
		randomTransitions.push({transition:"GradientSweep", easing:Strong.easeOut, duration:2, mode:"radial"});
		randomTransitions.push({transition:"GradientSweep", easing:Strong.easeOut, duration:2, mode:"top-left"});
		randomTransitions.push({transition:"GradientSweep", easing:Strong.easeOut, duration:2, mode:"bottom-right"});
		randomTransitions.push({transition:"GradientSweep", easing:Strong.easeOut, duration:2, mode:"bottom-left"});
		randomTransitions.push({transition:"GradientSweep", easing:Strong.easeOut, duration:2, mode:"top-right"});
		randomTransitions.push({transition:"Clock", easing:Strong.easeOut, duration:2, segments:1});
		randomTransitions.push({transition:"Clock", easing:Strong.easeOut, duration:2, segments:8});
		randomTransitions.push({transition:"Clock", easing:Strong.easeOut, duration:2, segments:4});
		randomTransitions.push({transition:"Clock", easing:Strong.easeOut, duration:2, segments:6});
		randomTransitions.push({transition:"Fly", easing:Back.easeOut, duration:2, mode:"top-left"});
		randomTransitions.push({transition:"Fly", easing:Back.easeOut, duration:2, mode:"bottom-right"});
		randomTransitions.push({transition:"Fly", easing:Back.easeOut, duration:2, mode:"left"});
		randomTransitions.push({transition:"Fly", easing:Back.easeOut, duration:2, mode:"right"});
		randomTransitions.push({transition:"Pixelate", easing:None.easeInOut, duration:2, geometric:true});
		randomTransitions.push({transition:"Ripples", easing:None.easeInOut, duration:2, dens:4});
		randomTransitions.push({transition:"Ripples", easing:None.easeInOut, duration:2, dens:3});
		randomTransitions.push({transition:"DreamWave", easing:None.easeInOut, duration:2, maxx:80,maxy:80});
		randomTransitions.push({transition:"DreamWave", easing:None.easeInOut, duration:2});
		
		// transitions classes
		//transitions["Twirl"]=Twirl;
		transitions["FlipPage3D"]=FlipPage3D;
		transitions["Shuffle"]=Shuffle;
		transitions["Fold"]=Fold;
		transitions["JigsawPuzzle"]=JigsawPuzzle;
		transitions["Masks"]=Masks;
		transitions["Blur"]=Blur;
		transitions["Dissolve"]=Dissolve;
		transitions["Blinds"]=Blinds;
		transitions["FadeTiles"]=FadeTiles;
		transitions["FlipTiles"]=FlipTiles;
		transitions["Cubes"]=Cubes;
		transitions["FlipPage"]=FlipPage;
		transitions["Slices"]=Slices;
		transitions["GradientMasks"]=GradientMasks;
		transitions["GradientSweep"]=GradientSweep;
		transitions["Ripples"]=Ripples;
		transitions["DreamWave"]=DreamWave;
		transitions["Fly"]=Fly;
		transitions["Clock"]=Clock;
		transitions["ScaleTiles"]=ScaleTiles;
		transitions["Pixelate"]=Pixelate;
		
		// include some easing functions
		easing["None"]=None.easeNone;
		easing["None.easeIn"]=None.easeIn;
		easing["None.easeOut"]=None.easeOut;
		easing["None.easeInOut"]=None.easeInOut;
		easing["Back.easeIn"]=Back.easeIn;
		easing["Back.easeOut"]=Back.easeOut;
		easing["Back.easeInOut"]=Back.easeInOut;
		easing["Bounce.easeIn"]=Bounce.easeIn;
		easing["Bounce.easeOut"]=Bounce.easeOut;
		easing["Bounce.easeInOut"]=Bounce.easeInOut;
		easing["Elastic.easeIn"]=Elastic.easeIn;
		easing["Elastic.easeOut"]=Elastic.easeOut;
		easing["Elastic.easeInOut"]=Elastic.easeInOut;
		easing["Regular.easeIn"]=Regular.easeIn;
		easing["Regular.easeOut"]=Regular.easeOut;
		easing["Regular.easeInOut"]=Regular.easeInOut;
		easing["Strong.easeIn"]=Strong.easeIn;
		easing["Strong.easeOut"]=Strong.easeOut;
		easing["Strong.easeInOut"]=Strong.easeInOut;
		
		// transition parameter types for converting
		parameters["_overlap"]="Number";
		parameters["_rows"]="int";
		parameters["_columns"]="int";
		parameters["_duration"]="Number";
		parameters["_ordering"]="String";
		parameters["_spin"]="String";
		parameters["_background"]="Boolean";
		parameters["_mode"]="String";
		parameters["_rotate"]="Boolean";
		parameters["_reverse"]="Boolean";
		parameters["_slicing"]="String";
		parameters["_direction"]="String";
		parameters["_direction_mode"]="String";
		parameters["_slices"]="int";
		parameters["_geometric"]="Boolean";
		parameters["_segments"]="int";
		parameters["_start_angle"]="Number";
		parameters["_clockwise"]="Boolean";
		parameters["_alternate"]="Boolean";
		parameters["_speedx"]="Number";
		parameters["_speedy"]="Number";
		parameters["_maxx"]="Number";
		parameters["_maxy"]="Number";
		parameters["_maxs"]="Number";
		parameters["_dens"]="Number";
		parameters["_type"]="String";
		parameters["_area"]="Number";
		parameters["_angle"]="Number";
				
		// read xml parameters file
		readXML();
	}
	
	private function hoverOn(e:Event=null)
	{
		controls2.visible=true;
		if (enableControls && !paused)
			controls.visible=true;
	}
	private function hoverOut(e:Event=null)
	{
		controls.visible=false;
		controls2.visible=false;
	}
	
	private function goPrev(e:Event=null)
	{
		doTransition("-1");
	}
	
	private function goNext(e:Event=null)
	{
		doTransition("+1");
	}
	
	private function readXML():void
	{
		loader = new URLLoader(new URLRequest(loaderInfo.parameters["xmlfile"]));
		loader.addEventListener(Event.COMPLETE, createSlideshow);
		xmlload=true;
	}
	
	/*private function findNext(d:int):void
	{
		previmg=currentimg;
		if (d==-1)
			currentimg=(currentimg+imgs.length-1)%imgs.length;
		else
			currentimg=(currentimg+1)%imgs.length;
	}*/
	
	private function progressHandler(e:LoaderEvent):void
	{
		var percent:Number;
		percent =((e.target.bytesLoaded/e.target.bytesTotal)+(currentimg))/xml_len;
		//loading.bar.scaleX=percent;
		loading.percent.text=int(percent*100)+"%";
		loading.message.text="image "+(currentimg+1)+" from "+xml_len;
	} 	
	
	private function createSlideshow(e:Event=null):void
	{
			var img:BitmapData,spr:Sprite;
			
			if (xmlload)
			{
				xml = new XML(e.target.data);
				if (xml.randomOrder!=undefined)
				{
					//trace(String(xml.randomOrder).toLowerCase());
					randomOrder=String(xml.randomOrder).toLowerCase()=="true";
				}
				if (xml.globalDelay!=undefined)
				{
					//trace(Number(String(xml.globalDelay)));
					delay=Number(String(xml.globalDelay));
				}
				if (xml.showControls!=undefined)
				{
					//trace(String(xml.randomOrder).toLowerCase());
					showControls=String(xml.showControls).toLowerCase()=="true";
				}
				
				if (xml.image!=undefined)
				{
					list = xml.image;
					xml_len=list.length();
				}
				else list=null;
				
				if (xml.showThumbnails!=undefined && String(xml.showThumbnails).toLowerCase()=="true")
				{
					thumbsize=Math.max(sh/5,70);// proportionately 100;
				}
				else thumbsize=0;
				
				// create container with transparent background
				container=new Sprite();
				container.graphics.beginFill(0,0);
				container.graphics.drawRect(0,0,sw,sh-thumbsize);
				container.graphics.endFill();
				
				xmlload=false;
				imgload=false;
				imgexists=false;
			}
			
			if ((list!=null) && (xml_len>0))
			{	
				if (!imgload)
				{
					++currentimg;
					if (sharedimgs[list[currentimg].@src]==null)
					{
						if (myloader!=null)
						{
							myloader.dispose(true);
						}
						myloader=new ImageLoader(list[currentimg].@src, {name:String(currentimg), container:container, smoothing:true, hAlign:"center", vAlign:"center", width:sw, height:sh-thumbsize, scaleMode:"proportionalInside", onComplete:createSlideshow, onError:createSlideshow, onProgress:progressHandler});
						imgload=true;
						myloader.load();
						//trace("Loading Image "+currentimg +" "+list[currentimg].@src);
					}
					else
					{
						imgexists=true;
						//trace("Image "+currentimg +" "+list[currentimg].@src+" exists");
					}
				}
				else
				{
					imgload=false;
					if ((e!=null && e.type==LoaderEvent.COMPLETE))
					{
						img=new BitmapData(sw,sh-thumbsize,true,0);
						img.draw(container);
						sharedimgs[list[currentimg].@src]={img:new Bitmap(img), i:currentimg};
						imgexists=false;						
					}
				}
				if (((e!=null && e.type==LoaderEvent.COMPLETE) || imgexists) && !imgload)
				{
					imgs.push({img:list[currentimg].@src, fx:{}, caption:(list[currentimg].caption!=undefined)?list[currentimg].caption:null, url:(list[currentimg].url!=-undefined)?list[currentimg].url:null});
					if (list[currentimg].fx!=undefined)
					{
						var atts:XMLList = list[currentimg].fx.attributes();
						for (var i:int = 0; i < atts.length(); i++)
						{
							var n:String=String(atts[i].name());
							var v=atts[i].toXMLString();
							var op:Object;
							op=getParameterWithType("_"+n,v);
							imgs[imgs.length-1].fx[n]=(op.t)((op.v) as (op.t));
						}
					}
					// add easing,delay,duration,transition defaults
					imgs[imgs.length-1].fx['easing']=(imgs[imgs.length-1].fx['easing']!=null)?easing[imgs[imgs.length-1].fx['easing']]:easingf;
					imgs[imgs.length-1].fx['duration']=(imgs[imgs.length-1].fx['duration']!=null)?imgs[imgs.length-1].fx['duration']:duration;
					imgs[imgs.length-1].fx['delay']=(imgs[imgs.length-1].fx['delay']!=null)?imgs[imgs.length-1].fx['delay']:delay;
					imgs[imgs.length-1].fx['transition']=(imgs[imgs.length-1].fx['transition']!=null)?imgs[imgs.length-1].fx['transition']:transitionf;
					//trace("Data for Image "+currentimg +" "+list[currentimg].@src);
					
					if (thumbsize>0)
					{
						if (imgexists)
						{
							//trace(sharedimgs[list[currentimg].@src].i);
							img=new BitmapData(thumbsa[sharedimgs[list[currentimg].@src].i].width,thumbsa[sharedimgs[list[currentimg].@src].i].height,true,0);
							img.draw(thumbsa[sharedimgs[list[currentimg].@src].i]);
							spr=new Sprite();
							spr.addChild(new Bitmap(img));
							thumbsa.push(spr);
							img=null;
							//trace("Thumb for Image "+currentimg +" "+list[currentimg].@src+" that exists");
						}
						else
						{
							//trace("Thumb for Image "+currentimg +" "+list[currentimg].@src+" that loads");
							var limg=container.getChildAt(0);
							removeChilds(container);
							limg.scaleX=thumbsize/limg.width;
							if (limg.scaleX*limg.height>thumbsize)
							{
								limg.scaleY=thumbsize/limg.height;
								limg.scaleX=limg.scaleY;
							}
							else
								limg.scaleY=limg.scaleX;
							img=new BitmapData(limg.width,limg.height,true,0);
							var scx=limg.scaleX;
							limg.scaleX=limg.scaleY=1;
							var mat=new Matrix();
							mat.createBox(scx,scx,0,0,0);
							img.draw(limg,mat);
							spr=new Sprite();
							spr.addChild(new Bitmap(img));
							//limg.bitmapData.dispose();
							limg=null;
							thumbsa.push(spr);
							img=null;
						}
					}
					imgexists=false;
					//trace("Finished Loading Image "+currentimg +" "+list[currentimg].@src);
				}
			}
			else 
			{
				removeChild(loading); 
				return; // nothing to do
			}
			if ((currentimg+1>=xml_len) && (imgload==false))
			{
				startSlideshow();
			}
			else if (imgload==false) createSlideshow();
	}
	
	private function startSlideshow():void
	{
		//trace("Start Slideshow");
		container=null;
		removeChild(loading); 
		if (imgs.length==0) return;
		currentimg=0;
		previmg=0;
		
		for (var i=0; i<imgs.length;i++)
		 ind[i]=i;
		if (randomOrder) // randomize image order
			ind=TransitionUtils.random(ind,0,0).pieces;
			
		// main holder of images slideshow
		holder=new Sprite();
		holder.y=thumbsize;
		addChild(holder);
		holder.buttonMode=true;
		holder.mouseEnabled=true;
		holder.addEventListener(MouseEvent.CLICK,gotoURL);
		
		// caption holder
		captionholder=new Sprite();
		addChild(captionholder);
		captiontext=new TextField();
		captiontext.x=10;
		captiontext.y=10;
		captiontext.autoSize=TextFieldAutoSize.LEFT;
		captiontext.multiline=true;
		//captiontext.wordWrap=true;
		txtFormat=new TextFormat();
		txtFormat.color=0xffffff;
		txtFormat.font="Arial";
		captiontext.defaultTextFormat=txtFormat;
		captionholder.addChild(captiontext);
		
		// show controls
		if (showControls)
		{
			controls=new Sprite();
			prevbt.addEventListener(MouseEvent.CLICK,goPrev);
			nextbt.addEventListener(MouseEvent.CLICK,goNext);
			prevbt.visible=true;
			nextbt.visible=true;
			prevbt.x=0;
			prevbt.y=0.5*(sh-prevbt.height);
			nextbt.x=sw-nextbt.width;
			nextbt.y=0.5*(sh-nextbt.height);
			controls.addChild(prevbt);
			controls.addChild(nextbt);
			controls.visible=false;
			addChild(controls);
			this.addEventListener(MouseEvent.MOUSE_OVER,hoverOn);
			this.addEventListener(MouseEvent.MOUSE_OUT,hoverOut);
			
			controls2=new Sprite();
			controls2.y=thumbsize+5;
			controls2.x=5;
			controls2.addChild(playbt);
			controls2.addChild(pausebt);
			playbt.x=0;
			playbt.y=0;
			pausebt.x=0;
			pausebt.y=0;
			pausebt.visible=true;
			playbt.addEventListener(MouseEvent.CLICK,resumePlay);
			pausebt.addEventListener(MouseEvent.CLICK,pausePlay);
			controls2.visible=false;
			addChild(controls2);
		}
		
		// show thumbs
		if (thumbsize>0)
		{
			thumbs=new Sprite();
			addChild(thumbs);
			gf=new GlowFilter(0xFF0000, 1.0, 2.0, 2.0, 50, 1, false, false);
			for (i=0;i<thumbsa.length;i++)
			{
				//trace("--"+i+" "+ind[i]+" "+thumbsa.length);
				thumbsa[ind[i]].x=i*(thumbsize+marg)+thumbsize/2-thumbsa[ind[i]].width/2;
				thumbsa[ind[i]].y=thumbsize/2-thumbsa[ind[i]].height/2;
				//thumbsa[ind[i]].alpha=0.6;
				thumbsa[ind[i]].buttonMode=true;
				thumbsa[ind[i]].name=String(i);
				//thumbsa[ind[i]].addEventListener(MouseEvent.MOUSE_OVER,thumbOver);
				//thumbsa[ind[i]].addEventListener(MouseEvent.MOUSE_OUT,thumbOut);
				thumbsa[ind[i]].addEventListener(MouseEvent.CLICK,thumbClick);
				thumbs.addChild(thumbsa[ind[i]] as Sprite);
			}
			thumbs.addEventListener(MouseEvent.ROLL_OVER,thumbsStartMove);
			thumbs.addEventListener(MouseEvent.ROLL_OUT,thumbsStopMove);
			
			// show first slideshow image thumb
			displayCurrent();
		}
		// show first slideshow image
		displayImage();
	}
	
	private function resumePlay(e:Event):void
	{
		paused=false;
		playbt.visible=false;
		pausebt.visible=true;
		doTransition("+1");
	}
	
	private function pausePlay(e:Event):void
	{
		if (timer!=null) timer.stop();
		pausebt.visible=false;
		playbt.visible=true;
		paused=true;
	}
	
	private function thumbsStartMove(e:Event):void
	{
		thumbs_move=true;
		this.addEventListener(Event.ENTER_FRAME,thumbsMove);
	}
	
	private function thumbsStopMove(e:Event):void
	{
		// bypass empty area of thumbs sprite
		if (mouseY>=thumbs.y && mouseY<=thumbs.y+thumbsize && mouseX>=0 && mouseX<=sw) return;
		this.removeEventListener(Event.ENTER_FRAME,thumbsMove);
		thumbs_move=false;
	}
	
	private function thumbsMove(e:Event):void
	{
		if (mouseY>=thumbs.y && mouseY<=thumbs.y+thumbsize && thumbs.x>sw-thumbs.width && mouseX>=9*sw/10 && mouseX<=sw)
		thumbs.x+=-5;
		else if (mouseY>=thumbs.y && mouseY<=thumbs.y+thumbsize && thumbs.x<0 && mouseX<=sw/10 && mouseX>=0)
		thumbs.x+=5;
	}
	
	/*private function thumbOver(e:Event):void
	{
		e.target.alpha=1.0;
	}
	
	private function thumbOut(e:Event):void
	{
		if (int(e.target.name)!=currentimg)
			e.target.alpha=0.6;
	}*/
	
	private function thumbClick(e:Event):void
	{
		if (enableControls && !paused)
			doTransition(e.target.name);
	}
	
	private function displayCaption():void
	{
		//trace(imgs[currentimg].caption.toXMLString());
		if (imgs[ind[currentimg]].caption!=null && imgs[ind[currentimg]].caption!="")
		{
			captiontext.htmlText=imgs[ind[currentimg]].caption;
			captionholder.graphics.clear();
			captionholder.graphics.beginFill(0x222222,0.6);
			captionholder.graphics.drawRect(0,0,sw,captiontext.height+20);
			captionholder.graphics.endFill();
			captionholder.x=0;
			//captionholder.y=sh-captionholder.height;
			//captionholder.alpha=0;
			captionholder.visible=true;
			captionholder.y=sh;
			TweenMax.to(captionholder, imgs[ind[currentimg]].fx.delay/3, {useFrames:false, y:sh-captionholder.height, ease:Back.easeOut});
		}
	}
	
	private function gotoURL(e:Event=null):void
	{
		if (imgs[ind[currentimg]].url!=null && imgs[ind[currentimg]].url!="")
			navigateToURL(new URLRequest(imgs[currentimg].url),"_blank");
	}
	
	private function removeChilds(where:DisplayObjectContainer):void
	{
		while (where.numChildren>0) where.removeChildAt(0);
	}
	
	private function displayImage(e:Event=null):void
	{
		if (imgs.length==0) return;
		removeChilds(holder);
		holder.addChild(sharedimgs[imgs[ind[currentimg]].img].img);
		displayCaption();
		if (timer!=null) timer.stop();
		if (!paused)
		{
		timer=new Timer(imgs[ind[currentimg]].fx.delay*1000, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE,doNext);
		enableControls=true;
		timer.start();
		}
	}
	
	private function displayCurrent():void
	{
		thumbsa[ind[previmg]].filters=[];
		thumbsa[ind[currentimg]].filters=[gf];
		//thumbsa[ind[previmg]].alpha=0.6;
		//thumbsa[ind[currentimg]].alpha=1.0;
		if (!thumbs_move)
		{
			if (thumbs.x+(currentimg+1)*(thumbsize+marg)>sw)
				thumbs.x-=(thumbs.x+(currentimg+1)*(thumbsize+marg)-sw);
			else if (thumbs.x+currentimg*(thumbsize+marg)<0)
				thumbs.x+=-(thumbs.x+currentimg*(thumbsize+marg));
		}
	}
	
	private function doNext(e:Event=null):void
	{
		doTransition("+1");
	}
	
	private function doTransition(d:String):void
	{
		//enableControls=false;
		if (imgs.length==0) return;
		if (timer!=null) timer.stop();
		/*if (showControls)
		{
			controls.visible=false;
			controls2.visible=false;
		}*/
		captionholder.visible=false;
		//findNext(d);
		previmg=currentimg;
		if (d=="-1")
			currentimg=(currentimg+imgs.length-1)%imgs.length;
		else if (d=="+1")
			currentimg=(currentimg+1)%imgs.length;
		else currentimg=int(d);
		
		var tempfx:Object;
		
		if (imgs[ind[currentimg]].fx['transition']=="random")
			tempfx=getRandomTransition();
		else
			tempfx=imgs[ind[currentimg]].fx;
		
		var fxClass:Class=transitions[tempfx['transition']];
		
		if (fx!=null) 
		{
			fx.removeEventListener(Transition.eventType,displayImage);
			if (timer==null)
			{
				fx.kill(); // kill if in action still
			}
		}
		removeChilds(holder);
		
		fx=new fxClass() as Transition;
		fx.addEventListener(Transition.eventType,displayImage);
		
		Transition.useFramesGlobal=false;
		Transition.persistGlobal=false;
		Transition.startNowGlobal=true;
		Transition.dispatchGlobal=true;
		Transition.useGlobal=true;
		
		// add fx parameters
		fxparams={};
		for (var att in tempfx)
		{
			fxparams[att]=tempfx[att];
		}
		fxparams.toTarget=sharedimgs[imgs[currentimg].img].img;
		fxparams.fromTarget=sharedimgs[imgs[previmg].img].img;
		
		if (thumbsize>0)
		{
			displayCurrent();
		}
		holder.addChild(fx);
		
		fx.doit(fxparams);
		timer=null;
	}
	
	private function getRandomTransition():Object
	{
		return(randomTransitions[Math.round(Math.random()*(randomTransitions.length-1))]);
	}
	
	private function getParameterWithType(name:String,val:String):Object
	{
		switch(parameters[name])
		{
			case "int": return({v:int(val),t:int});
			case "Number":return({v:Number(val),t:Number});
			case "Boolean": if (val.toLowerCase()=="true") return({v:true,t:Boolean});
							return({v:false,t:Boolean});
			default: return({v:val,t:String});
		}
	}
}
}