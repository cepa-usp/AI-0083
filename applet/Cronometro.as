package  
{
	import cepa.utils.Cronometer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Luciano
	 */
	public class Cronometro extends MovieClip
	{
		var cronometer:Cronometer = new Cronometer();
		
		public function Cronometro() 
		{
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.segundos.text = "0";
			this.decimos.text = "0";
			
			var timer:Timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, atualiza);
			timer.start();
			
			this.start_btn.addEventListener(MouseEvent.CLICK, startStopClock);
			this.reset_btn.addEventListener(MouseEvent.CLICK, resetClock);
		}
		
		private function atualiza(event:TimerEvent):void {
			if (cronometer.read() >= 60000) cronometer.reset();
			var t:Number = cronometer.read() / 1000;
			this.segundos.text = Math.floor(t).toString();
			this.decimos.text = Math.floor((t - Math.floor(t)) * 10).toString();
		}
		
		private function startStopClock(event:MouseEvent):void {
			if (cronometer.isRunning()) cronometer.pause();
			else cronometer.start();
			if (event.target.currentFrame == 1) event.target.gotoAndStop(2);
			else event.target.gotoAndStop(1);
		}
		
		public function resetClock(event:MouseEvent):void {
			this.segundos.text = "0";
			this.decimos.text = "0";
			cronometer.stop();
			event.target.gotoAndStop(1);
			start_btn.gotoAndStop(1);
		}
		
		public function isRunning():Boolean
		{
			return cronometer.isRunning();
		}
		
		public function pause():void
		{
			cronometer.pause();
		}
		
		public function start():void
		{
			cronometer.start();
		}
		
	}
}