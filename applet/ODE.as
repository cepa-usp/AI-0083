package 
{
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public interface ODE 
	{
		function ODE( order:int ):void;
		function setOrder( order:int ):void;
		function getOrder():int;
		
		/*
		 * Funcional que define a equação diferencial ordinária. Por exemplo,
		 * y''' = F(x,y,y',y'')
		 * 
		 * x é a variável independente e y[j] a j-ésima derivada de y.
		 * O objetivo da EDO é determinar y[n], sendo n a ordem da EDO.
		 */
		function F( x:Number, y:Array ):Number;
	}
	
}