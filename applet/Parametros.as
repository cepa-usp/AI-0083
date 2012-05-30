package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Parametros extends MovieClip
	{
		private var posClick:Point;
		
		public var teta:Number;
		public var massa:Number;
		public var comprimento:Number;
		public var gravidade:Number;
		public var periodo:Number;
		public var velocidadeMax:Number;
		
		public var showGravity:Boolean;
		
		public function Parametros() 
		{
			initParameters();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		public function getTeta():Number{
			return teta;
		}
		
		public function getMassa():Number{
			return massa;
		}
		
		public function getComprimento():Number{
			return comprimento;
		}
		
		public function getGravidade():Number{
			return gravidade;
		}
		
		public function getPeriodo():Number{
			return periodo;
		}
		
		public function getVelocidade():Number{
			return velocidadeMax;
		}
		
		public function initParameters():void
		{
			teta = 0;
			massa = 5;
			comprimento = 5;
			gravidade = 10;
			periodo = 0;
			velocidadeMax = 0;
			
			this.visible = false;
			//openParametros();
			this.x = 475;
			this.y = 10;
			
			showGravity = true;
		}
		
		public function openParametros():void
		{
			tetaText.background = false;
			massaText.background = false;
			comprimentoText.background = false;
			gravidadeText.background = false;
			
			tetaText.text = String(teta);
			massaText.text = String(massa);
			comprimentoText.text = String(comprimento);
			gravidadeText.text = String(gravidade);
			
			gravidadeText.visible = showGravity;
			fundoGravidade.visible = showGravity;
			
			this.visible = true;
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			//trace(e.target.name);
			if (e.target is Parametros)
			{
				posClick = new Point(this.mouseX, this.mouseY);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopMoving);
			}
			else if (e.target is TextField)
			{
				removeBgColor(TextField(e.target));
			}
			else
			{
				if (e.target.name == "okButton") 
				{
					if (getParameters()) 
					{
						dispatchEvent(new Event("OK_PRESSED", true));
						this.visible = false;
					}
					
				}
				else if (e.target.name == "cancelButton") 
				{
					dispatchEvent(new Event("CANCEL_PRESSED", true));
					this.visible = false;
				}
			}
		}
		
		private function getParameters():Boolean
		{
			stage.focus = null;
			if(tetaText.text != "") teta = Number(tetaText.text.replace(",","."));
			if(massaText.text != "") massa = Number(massaText.text.replace(",","."));
			if(comprimentoText.text != "") comprimento = Number(comprimentoText.text.replace(",","."));
			if(gravidadeText.text != "") gravidade = Number(gravidadeText.text.replace(",","."));
			
			var retorno:Boolean = true;
			
			if (isNaN(teta)) 
			{
				TextField(tetaText).background = true;
				TextField(tetaText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			else if (teta < -179 || teta > 180)
			{
				TextField(tetaText).background = true;
				TextField(tetaText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			
			if (isNaN(massa)) 
			{
				TextField(massaText).background = true;
				TextField(massaText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			else if (massa < 1 || massa > 10)
			{
				TextField(massaText).background = true;
				TextField(massaText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			
			if (isNaN(comprimento)) 
			{
				TextField(comprimentoText).background = true;
				TextField(comprimentoText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			else if (comprimento < 1 || comprimento > 10)
			{
				TextField(comprimentoText).background = true;
				TextField(comprimentoText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			
			if (isNaN(gravidade)) 
			{
				TextField(gravidadeText).background = true;
				TextField(gravidadeText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			else if (gravidade < 1 || gravidade > 25)
			{
				TextField(gravidadeText).background = true;
				TextField(gravidadeText).backgroundColor = 0xFF0000;
				retorno = false;
			}
			
			return retorno;
		}
		
		private function setWrongText(tf:TextField):void
		{
			tf.background = true;
			tf.backgroundColor = 0xFF0000;
		}
		
		private function removeBgColor(tf:TextField):void
		{
			tf.background = false;
		}
		
		private function moving(e:MouseEvent):void 
		{
			this.x = Math.max(-this.width / 2, Math.min(stage.stageWidth - this.width / 2, stage.mouseX - posClick.x));
			this.y = Math.max(-this.height / 2, Math.min(stage.stageHeight - this.height / 2, stage.mouseY - posClick.y));
		}
		
		private function stopMoving(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moving);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMoving);
		}
		
		
	}

}