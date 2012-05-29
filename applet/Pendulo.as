package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class  Pendulo extends Sprite implements ODE
	{
		private var order:int = 2;
		private var L:Number = 5;
		private var g:Number = 10;
		private var tPeriodo:Number = 0;
    
		public function Pendulo():void
		{
			setOrder(2);
			this.bolaPendulo.addEventListener(MouseEvent.MOUSE_DOWN, initArraste);
		}
		
		public function setOrder( order:int ):void
		{
			if ( order >= 0 ) this.order = order;
		}
		
		public function getOrder():int
		{
			return order;
		}
		
		public function setL(comprimento:Number):void
		{
			if (comprimento > 0) this.L = comprimento;
		}
		
		public function setG(gravidade:Number):void
		{
			this.g = gravidade;
		}
		
		public function setPeriodo(tempoPeriodo:Number):void
		{
			this.tPeriodo = tempoPeriodo;
		}
		
		public function get periodo():Number
		{
			return tPeriodo;
		}
		
		/*
		 * Funcional que define a equação diferencial ordinária. Por exemplo,
		 * y''' = F(x,y,y',y'')
		 * 
		 * x é a variável independente e y[j] a j-ésima derivada de y.
		 * O objetivo da EDO é determinar y[n], sendo n a ordem da EDO.
		 */
		public function F( x:Number, y:Array ):Number 
		{
			return -g/L * Math.sin(y[0]);
		}
		
		private function initArraste(e:MouseEvent):void 
		{
			dispatchEvent(new Event("INICIANDO_ARRASTE", true));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, rotatingPendulo);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopArraste);
		}
		
		private function rotatingPendulo(e:MouseEvent):void 
		{
			this.rotation = Math.atan2(stage.mouseY - this.y, stage.mouseX - this.x) * 180/Math.PI - 90;
		}
		
		private function stopArraste(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotatingPendulo);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopArraste);
			
			dispatchEvent(new Event("PAROU_ARRASTE", true));
			
		}
		
		public function set rotacao(angulo:Number):void
		{
			this.rotation = angulo;
		}
	}
	
}