﻿package cepa.LO.tools
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public class Tool_Regua extends MovieClip {
		
		private var _ruler:Ruler = new Ruler();
		private var rulerWidth:uint = 225;//450;
		private var rulerHeight:uint = 100;//150;
		private var startAngle:Number;
		private var rotating:Boolean;
		private var bigTickMm:Array = new Array();
		private var MiliToPix = 0.4285// * 2;
		private var startOrientation:Number;
		private var arrayAtractors:Array = new Array();
		private var clickOfSet:Point = new Point();
		private var i:Number;
		private var visivel:Boolean = false;
		
		
		
		public function Tool_Regua()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{			
			rotating = false;
			addChild(ruler);
			//rulerWidth = 500 * MiliToPix + 30;
//			ruler.transform.colorTransform = new ColorTransform(1,1,1,0.2);
			//ruler.scaleX = ruler.scaleY = 0.52;
			ruler.base.width = rulerWidth;
			ruler.right.x = -4.5 + rulerWidth;
			ruler.mov.width = rulerWidth + 25;
			ruler.rot.width = rulerWidth + 25;
			//ruler.scaleY = 0.52;
			ruler.rot.gotoAndStop(1);
			ruler.mov.gotoAndStop(1);
			doTheTicks();
			addEventListener(MouseEvent.MOUSE_DOWN, rotateRuler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, overOut);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveEvent);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);
		}
		
		private function overOut(e:MouseEvent):void 
		{
			if (MovieClip(ruler.rot).hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				ruler.rot.gotoAndStop(2);
			}else {
				ruler.rot.gotoAndStop(1);
			}
			
			if (MovieClip(ruler.mov).hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				ruler.mov.gotoAndStop(2);
			}else {
				ruler.mov.gotoAndStop(1);
			}
		}
		
		private function stopMove(event:MouseEvent):void {
			//stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMove);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingRuler);
		}
		
		public function rotateRuler(event:MouseEvent) : void {
			//if (event.target.mouseY < -90) {
			trace(this.mouseY);
			if (this.mouseY <= 15) {
				rotating = true;
				startAngle = (Math.atan2(stage.mouseY - y, stage.mouseX - x)) * 180 / Math.PI;
				startOrientation = rotation;
			} else {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, movingRuler);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopMove);
				clickOfSet.x = stage.mouseX - x;
				clickOfSet.y = stage.mouseY - y;
			}
		}
		
		private function movingRuler(e:MouseEvent):void {
			if (arrayAtractors.length > 0)
			{
				for (i = 0; i < arrayAtractors.length; i++)
				{
					if ((stage.mouseX-clickOfSet.x > arrayAtractors[i].x - 10 && stage.mouseX-clickOfSet.x < arrayAtractors[i].x + 10) &&
					   (stage.mouseY-clickOfSet.y > arrayAtractors[i].y - 10 && stage.mouseY-clickOfSet.y < arrayAtractors[i].y + 10))
					{
						x = arrayAtractors[i].x;
						y = arrayAtractors[i].y;
						break;
					}
					else
					{
						x = stage.mouseX - clickOfSet.x;
						y = stage.mouseY - clickOfSet.y;
					}
				}
			}
			else
			{
				x = stage.mouseX - clickOfSet.x;
				y = stage.mouseY - clickOfSet.y;
			}
		}
		
		private function onMouseMoveEvent(event:MouseEvent) : void {
			if (rotating) rotation = Math.round((Math.atan2(stage.mouseY - y, stage.mouseX - x)) * 180 / Math.PI - startAngle + startOrientation);
		}		
		private function onMouseUpEvent(event:MouseEvent) : void {
			rotating = false;
		}
		
		public function get angulo() : Number {
			return rotation;
		}
		
		public function set angulo (rotation:Number) : void {
			this.rotation = rotation;
		}
		
		public function set atractors(listaAtractor:Array):void
		{
			arrayAtractors = listaAtractor;
		}
		
		public function get ruler():Ruler 
		{
			return _ruler;
		}
		
		public function set ruler(value:Ruler):void 
		{
			_ruler = value;
		}
		
		public function open():void
		{
			this.visible = true;
			visivel = true;
		}
		
		public function close():void
		{
			this.visible = false;
			visivel = false;
		}
		
		public function rulerVisible():void
		{
			if (this.visible)
			{
				this.visible = false;
				visivel = false;
			}
			else
			{
				this.visible = true;
				visivel = true;
			}
		}
		
		public function retornaVisibilidade():Boolean
		{
			return visivel;
		}
		
		public function setAlpha(alphaValue:Number):void	{
			this.ruler.alpha = alphaValue;
		}
		
		private function doTheTicks():void {
			for (var m = 0; m <= 500; m = m + 10) {  // Desenha os ticks
				bigTickMm[m] = new Cent();
				bigTickMm[m].unit.text = m / 50;
				if ((m / 50) - (Math.floor(m / 50)) != 0) bigTickMm[m].unit.visible = false; // Define como invisível os valores não-múltiplos de 50
				else bigTickMm[m].tick.scaleY = 1.5;
				bigTickMm[m].unit.y += 5;
				bigTickMm[m].x = ruler.x + (m * MiliToPix);
				bigTickMm[m].y = ruler.y;// + 5;
				addChild(bigTickMm[m]);
			}
		}
	}
}
