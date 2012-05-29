package 
{
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class VanDerPol implements ODE 
	{
		private var order:int = 2;
		private var L:Number = 1;
		private var g:Number = 10;
		private var epsilon:Number = 0.9;
    
		public function VanDerPol():void{
			setOrder(2);
		}
		public function setOrder( order:int ):void{
			if ( order >= 0 ) this.order = order;
		}
		public function getOrder():int{
			return order;
		}
		
		/*
		 * Funcional que define a equação diferencial ordinária. Por exemplo,
		 * y''' = F(x,y,y',y'')
		 * 
		 * x é a variável independente e y[j] a j-ésima derivada de y.
		 * O objetivo da EDO é determinar y[n], sendo n a ordem da EDO.
		 */
		public function F( x:Number, y:Array ):Number {
			return -y[0] - epsilon * ( y[0] * y[0] - 1.0 ) * y[1];
		}
	}
	
}