package  
{
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class JanelaGrafico extends MovieClip
	{
		private var graph:SimpleGraph;
		
		private var pontosTetaxT:Array;
		private var pontosPhixT:Array;
		private var pontosDTetaxTeta:Array;
		private var pontosDPhixPhi:Array;
		private var pontosDTetaxT:Array;
		private var pontosDPhixT:Array;
		
		private var style1:DataStyle;
		private var style2:DataStyle;
		private var style3:DataStyle;
		private var style4:DataStyle;
		private var style5:DataStyle;
		private var style6:DataStyle;
		
		private var radio1Selec:Boolean;
		private var pontoGrafico1:Ponto1;
		private var pontoGrafico2:Ponto2;
		
		private var maxYRadio1:Number;
		private var maxYRadio2:Number;
		private var posClick:Point;
		
		public function JanelaGrafico() 
		{
			this.x = 65;
			this.y = 40;
			
			this.visible = false;
			radio1Selec = true;
			
			check1.enabled = true;
			check3.enabled = true;
			check4.enabled = true;
			check2.enabled = false;
			
			configGraph();
			addListeners();
		}
		
		private function configGraph():void
		{
			maxYRadio1 = 0;
			maxYRadio2 = 0;
			var xMin:Number = 0;
			var xMax:Number = 20;
			var largura:Number = 541;
			var yMin:Number = -0.5;
			var yMax:Number = 0.5;
			var altura:Number = 343;
			
			if (graph != null) 
			{
				removeChild(graph);
				graph == null;
			}
			
			graph = new SimpleGraph(xMin, xMax, largura, yMin, yMax, altura);
			graph.setTicksDistance(SimpleGraph.AXIS_X, 1);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, 0.5);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
			graph.grid = false;
			
			graph.setAxesNameFormat(new TextFormat("arial", 12, 0x000000));
			graph.setAxisName(SimpleGraph.AXIS_Y, "ângulo (rad) ou velocidade angular (rad/s)");
			graph.setAxisName(SimpleGraph.AXIS_X, "t(s)");
			
			graph.x = 29;
			graph.y = 1;
			
			graph.resolution = 3;
			
			this.addChild(graph);
			
			style1 = new DataStyle();
			style1.color = 0xFF0000;
			style2 = new DataStyle();
			style2.color = 0x008000;
			style3 = new DataStyle();
			style3.color = 0x0000FF;
			style4 = new DataStyle();
			style4.color = 0xFF00FF;
			style5 = new DataStyle();
			style5.color = 0x6600FF;
			style6 = new DataStyle();
			style6.color = 0x000000;
			
			pontosTetaxT = [];
			pontosPhixT = [];
			pontosDTetaxTeta = [];
			pontosDPhixPhi = [];
			pontosDTetaxT = [];
			pontosDPhixT = [];
			
			pontoGrafico1 = new Ponto1();
			pontoGrafico2 = new Ponto2();
			
			//graph.addData(pontosTetaxT, style1);
		}
		
		private function addListeners():void
		{
			radio1.addEventListener(MouseEvent.CLICK, radioClick);
			radio2.addEventListener(MouseEvent.CLICK, radioClick);
			
			check1.addEventListener(MouseEvent.CLICK, checkClick);
			check2.addEventListener(MouseEvent.CLICK, checkClick);
			check3.addEventListener(MouseEvent.CLICK, checkClick);
			check4.addEventListener(MouseEvent.CLICK, checkClick);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, initArraste);
		}
		
		private function initArraste(e:MouseEvent):void 
		{
			if (e.target is JanelaGrafico)
			{
				posClick = new Point(this.mouseX, this.mouseY);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopMoving);
			}
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
		
		private function radioClick(e:MouseEvent):void 
		{
			if (e.target.name == "radio1")
			{
				graph.pan = false;
				graph.setAxisName(SimpleGraph.AXIS_Y, "ângulo (rad) ou velocidade angular (rad/s)");
				graph.setAxisName(SimpleGraph.AXIS_X, "t(s)");
				if (!radio1Selec && pontosDTetaxTeta[0] != null)
				{
					maxYRadio2 = graph.ymax;
					radio1Selec = true;
					redefineGraph(e.target.name);
					graph.removeData(pontosDTetaxTeta);
					graph.removePoint(pontoGrafico1);
					graph.addData(pontosTetaxT, style1);
				}
				if (check2.selected) 
				{
					graph.removeData(pontosDPhixPhi);
					graph.removePoint(pontoGrafico2);
					check2.selected = false;
				}
				check1.enabled = true;
				check3.enabled = true;
				check4.enabled = true;
				check2.enabled = false;
				
				//graphLabel.gotoAndStop(1);
				//graphLabel.x = 36;
				//graphLabel.y = 0;
			}
			else
			{
				graph.pan = true;
				graph.setAxisName(SimpleGraph.AXIS_Y, "velocidade angular (rad/s)");
				graph.setAxisName(SimpleGraph.AXIS_X, "ângulo (rad)");
				if (radio1Selec && pontosTetaxT[0] != null)
				{
					maxYRadio1 = graph.ymax;
					redefineGraph(e.target.name);
					radio1Selec = false;
					graph.removeData(pontosTetaxT);
					graph.addData(pontosDTetaxTeta, style3);
					graph.addPoint(pontoGrafico1);
				}
				if (check1.selected) 
				{
					graph.removeData(pontosPhixT);
					check1.selected = false;
				}
				if (check3.selected) 
				{
					graph.removeData(pontosDTetaxT);
					check3.selected = false;
				}
				if (check4.selected) 
				{
					graph.removeData(pontosDPhixT);
					check4.selected = false;
				}
				check1.enabled = false;
				check3.enabled = false;
				check4.enabled = false;
				check2.enabled = true;
				
				//graphLabel.gotoAndStop(2);
				//graphLabel.x = 36;
				//graphLabel.y = 0;
			}
			//redefineGraph(e.target.name);
			//graph.draw();
		}
		
		private function redefineGraph(radioName:String):void
		{
			var xMin:Number;
			var xMax:Number;
			var yMin:Number;
			var yMax:Number;
				
			if (radioName == "radio1")
			{
				xMin = 0;
				xMax = 20;
				if (maxYRadio1 != 0)
				{
					yMin = -maxYRadio1;
					yMax = maxYRadio1;
				}
				else
				{
					yMin = -0.5;
					yMax = 0.5;
				}
				//graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
				graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			}
			else
			{
				xMin = -3.5;
				xMax = 3.5;
				yMin = -5;
				yMax = 5;
				//if (maxYRadio2 != 0)
				//{
					//yMin = -maxYRadio2;
					//yMax = maxYRadio2;
				//}
				//else
				//{
					//yMin = -2;
					//yMax = 2;
				//}
				//graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
				//graph.setSubticksDistance(SimpleGraph.AXIS_X, 0.1);
			}
			
			graph.xmin = xMin;
			graph.xmax = xMax;
			graph.ymin = yMin;
			graph.ymax = yMax;
			
			//graph.draw();
		}
		
		public function redefineLimites(aumenta:Boolean):void
		{
			if (radio2.selected)
			{
				if (aumenta)
				{
					graph.xmin += graph.xmin/10;
					graph.xmax += graph.xmax/10;
					graph.ymin += graph.ymin/10;
					graph.ymax += graph.ymax/10;
				}
				else
				{
					graph.xmin -= graph.xmin/10;
					graph.xmax -= graph.xmax/10;
					graph.ymin -= graph.ymin/10;
					graph.ymax -= graph.ymax/10;
				}
			}
			
			var subTickDistanceX:Number;
			var subTickDistanceY:Number;
			
			if (graph.xmax < 2) 
			{
				subTickDistanceX = 0.1;
				subTickDistanceY = 0.1;
				
			}
			else if (graph.xmax < 6) 
			{
				subTickDistanceX = 0.5;
				subTickDistanceY = 0.5;
			}
			else if (graph.xmax >= 10) 
			{
				subTickDistanceX = 1;
				subTickDistanceY = 0.5;
			}
			
			
			graph.setSubticksDistance(SimpleGraph.AXIS_X, subTickDistanceX);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, subTickDistanceY);
			
			//graph.setTicksDistance(SimpleGraph.AXIS_X, graph.xmax);
			//graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			//graph.setTicksDistance(SimpleGraph.AXIS_Y, 0.5);
			//graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
			
			graph.draw();
		}
		
		private function checkClick(e:MouseEvent):void 
		{
			if (radio1.selected)
			{
				switch(e.target.name)
				{
					case "check1":
						if (check1.selected == false) graph.removeData(pontosPhixT);
						else graph.addData(pontosPhixT, style2);
						//graph.draw();
						break;
					case "check3":
						if (check3.selected == false) graph.removeData(pontosDTetaxT);
						else graph.addData(pontosDTetaxT, style5);
						//graph.draw();
						break;
					case "check4":
						if (check4.selected == false) graph.removeData(pontosDPhixT);
						else graph.addData(pontosDPhixT, style6);
						//graph.draw();
						break;
					case "check2":
						check2.selected = false;
						//graph.draw();
						break;
				}
			}
			else 
			{
				switch(e.target.name)
				{
					case "check1":
						check1.selected = false;
						//graph.draw();
						break;
					case "check3":
						check3.selected = false;
						//graph.draw();
						break;
					case "check4":
						check4.selected = false;
						//graph.draw();
						break;
					case "check2":
						if (check2.selected == false) 
						{
							graph.removeData(pontosDPhixPhi);
							graph.removePoint(pontoGrafico2);
						}
						else 
						{
							graph.addData(pontosDPhixPhi, style4);
							graph.addPoint(pontoGrafico2);
						}
						//graph.draw();
						break;
				}
			}
		}
		
		public function addPoint(tetaxT:Array, phixT:Array, dThetaxTeta:Array, dPhixPhi:Array, dTetaxT:Array, dPhixT:Array):void
		{
			
			pontosTetaxT.push(tetaxT);
			pontosPhixT.push(phixT);
			pontosDTetaxTeta.push(dThetaxTeta);
			pontosDPhixPhi.push(dPhixPhi);
			pontosDTetaxT.push(dTetaxT);
			pontosDPhixT.push(dPhixT);
			
			if (this.visible)
			{
				if (radio1.selected)
				{
					if (tetaxT[0] >= graph.xmax - 5)
					{
						graph.xmax = tetaxT[0] + 5;
						graph.xmin = graph.xmax - 20;
					}
					//if (tetaxT[0] >= graph.xmax - 5)
					//{
						//graph.xmin += 1/30;
						//graph.xmax += 1/30;
					//}
					if (tetaxT[1] >= graph.ymax - 0.5 || phixT[1] >= graph.ymax - 0.5 || dThetaxTeta[1] >= graph.ymax - 0.5 || dPhixPhi[1] >= graph.ymax - 0.5 || dTetaxT[1] >= graph.ymax - 0.5 || dPhixT[1] >= graph.ymax - 0.5 ||
						tetaxT[1] <= graph.ymin + 0.5 || phixT[1] <= graph.ymin + 0.5 || dThetaxTeta[1] <= graph.ymin + 0.5 || dPhixPhi[1] <= graph.ymin + 0.5 || dTetaxT[1] <= graph.ymin + 0.5 || dPhixT[1] <= graph.ymin + 0.5)
					{
						graph.ymin -= 0.1;
						graph.ymax += 0.1;
					}
				}
				else
				{
					//if (dPhixPhi[1] >= graph.ymax - 0.5 || dPhixPhi[1] <= graph.ymin + 0.5)
					//{
						//graph.ymax += 0.5;
						//graph.ymin -= 0.5;
					//}
					
					pontoGrafico1.xpos = dThetaxTeta[0];
					pontoGrafico1.ypos = dThetaxTeta[1];
					
					if (graph.inRange(pontoGrafico1.xpos, pontoGrafico1.ypos)) pontoGrafico1.visible = true;
					else pontoGrafico1.visible = false;
					
					if (check2.selected)
					{
						pontoGrafico2.xpos = dPhixPhi[0];
						pontoGrafico2.ypos = dPhixPhi[1];
						
						if (graph.inRange(pontoGrafico2.xpos, pontoGrafico2.ypos)) pontoGrafico2.visible = true;
						else pontoGrafico2.visible = false;
					}
				}
			}
			
			if (pontosTetaxT.length > 600)
			{
				pontosTetaxT.splice(0, 1);
				pontosPhixT.splice(0, 1);
				pontosDTetaxTeta.splice(0, 1);
				pontosDPhixPhi.splice(0, 1);
				pontosDTetaxT.splice(0, 1);
				pontosDPhixT.splice(0, 1);
			}
			
			if(this.visible) graph.draw();
		}
		
		public function resetGrafico():void
		{
			if (radio2.selected)
			{
				graph.removeData(pontosDTetaxTeta);
				graph.removePoint(pontoGrafico1);
				
				if (check2.selected)
				{
					graph.removeData(pontosDPhixPhi);
					graph.removePoint(pontoGrafico2);
				}
			}
			else
			{
				graph.removeData(pontosTetaxT);
				
				if (check1.selected)
				{
					graph.removeData(pontosPhixT);
				}
				if (check3.selected)
				{
					graph.removeData(pontosDTetaxT);
				}
				if (check4.selected)
				{
					graph.removeData(pontosDPhixT);
				}
			}
			
			radio1Selec = true;
			
			maxYRadio1 = 0;
			maxYRadio2 = 0;
			
			redefineGraph("radio1");
			graph.draw();
			
			pontosTetaxT = [];
			pontosPhixT = [];
			pontosDTetaxTeta = [];
			pontosDPhixPhi = [];
			pontosDPhixT = [];
			pontosDTetaxT = [];
			
			graph.addData(pontosTetaxT, style1);
			radio1.selected = true;
			radio2.selected = false;
			
			check1.selected = false;
			check2.selected = false;
			check3.selected = false;
			check4.selected = false;
			
			check1.enabled = true;
			check3.enabled = true;
			check4.enabled = true;
			check2.enabled = false;
			
			this.x = 65;
			this.y = 40;
		}
		
	}

}