package 
{
	import BaseAssets.BaseMain;
	import cepa.utils.Cronometer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain 
	{
		private const MAX_FRAMES:int = 5000;
		
		private var t:Array;
		private var posX:Array;
		
		private var pendulo:Pendulo;
		private var solver:RungeKuttaCashKarpSolver;
		//private var A:Number = 30 * Math.PI / 180;
		private var dt:Number = 1/30;
		
		private var posArray:int;
		private var cronometer:Cronometer;
		private var inicioZero:Boolean;
		private var mudaArray:Boolean;
		private var posXAux:Array;
		private var parametros:Parametros;
		
		private var transferidor:Tool_Transferidor;
		private var posClick:Point;
		private var posPendulo:Point;
		private var cronometro:Cronometro;
		
		private var grafico:JanelaGrafico;
		private var cronoGrafico:Cronometer;
		private var penduloClassico:PenduloClassico;
		private var nAtualizacao:int;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			configPendulo();
			
			initVariables();
			
			addListeners();
			
			addExternalInterfaces();
		}
		
		private function addExternalInterfaces():void
		{
			if (ExternalInterface.available)
			{
                try
				{
                    ExternalInterface.addCallback("getTeta", parametros.getTeta);
					ExternalInterface.addCallback("getMassa", parametros.getMassa);
					ExternalInterface.addCallback("getComprimento", parametros.getComprimento);
					ExternalInterface.addCallback("getGravidade", parametros.getGravidade);
					ExternalInterface.addCallback("getPeriodo", parametros.getPeriodo);
					ExternalInterface.addCallback("getVelocidade", parametros.getVelocidade);
					ExternalInterface.addCallback("getSolution", getSolution);
					
					ExternalInterface.addCallback("setGravity", setGravity);
					ExternalInterface.addCallback("setTeta", setTeta);
					ExternalInterface.addCallback("showHideMHS", showHideMHS);
					ExternalInterface.addCallback("playAnimation", playAnimation);
					ExternalInterface.addCallback("showHideGravidade", showHideGravidade);
					ExternalInterface.addCallback("doNothing", doNothing);
					
					ExternalInterface.addCallback("pause", flashDeactive);
					ExternalInterface.addCallback("play", flashActive);
                }
				catch (error:SecurityError)
				{
					trace("Ocorreu um erro de segurança: " + error.message);
                }
				catch (error:Error)
				{
					trace("Ocorreu um erro: " + error.message);
                }
            }
			else
			{
				trace("External interface is not available for this container.");
            }
		}
		
		private function doNothing():Boolean 
		{
			return true;
		}
		
		private function getSolution():String
		{
			var stringRetorno:String = "";
			
			for (var i:int = 0; i < posX.length; i++) 
			{
				stringRetorno.concat(String(t[i]) + "\t" + String(posX[i][0]) + "\t" + String(posX[i][1]) + "\n");
			}
			
			return stringRetorno;
		}
		
		private function initVariables():void
		{
			if (parametros == null)
			{
				parametros = new Parametros();
				addChild(parametros);
			}
			
			calculando.visible = false;
			calculando.gotoAndStop(1);
			
			cronometer = new Cronometer();
			
			if (transferidor == null)
			{
				transferidor = new Tool_Transferidor();
				addChild(transferidor);
				transferidor.atractors = [new Point(pendulo.x, pendulo.y)];
			}
			transferidor.x = stage.stageWidth / 2;
			transferidor.y = stage.stageHeight / 2;
			transferidor.visible = false;
			
			
			if (cronometro == null) 
			{
				cronometro = new Cronometro();
				addChild(cronometro);
			}
			cronometro.visible = false;
			cronometro.x = cronometro.width / 2 + 45;
			cronometro.y = cronometro.height / 2 + 5;
			
			if (grafico == null)
			{
				grafico = new JanelaGrafico();
				addChild(grafico);
			}
			
			cronoGrafico = new Cronometer();
			
			menu.grafico.alpha = 0.5;
			menu.grafico.filters = [GRAYSCALE_FILTER];
			menu.grafico.mouseEnabled = false;
			grafico.visible = false;
			
			penduloClassico.visible = false;
			
			menu.openTransfer.gotoAndStop(1);
			menu.showHidePC.gotoAndStop(2);
			menu.grafico.gotoAndStop(1);
			menu.cronometro.gotoAndStop(1);
			menu.parametros.gotoAndStop(1);
			
			menu.openTransfer.buttonMode = true;
			menu.showHidePC.buttonMode = true;
			menu.grafico.buttonMode = true;
			menu.cronometro.buttonMode = true;
			menu.parametros.buttonMode = true;
			
			makeBtn(menu.openTransfer);
			makeBtn(menu.showHidePC);
			makeBtn(menu.grafico);
			makeBtn(menu.cronometro);
			makeBtn(menu.parametros);
			
			nAtualizacao = 0;
			
			menu.filters = [new DropShadowFilter(3, 45, 0x000000, 1, 5, 5)];
		}
		
		private var btnScale:Number = 0.9;
		private function makeBtn(btn:*):void
		{
			btn.scaleX = btn.scaleY = btnScale;
			btn.addEventListener(MouseEvent.MOUSE_OVER, overBtn);
			btn.addEventListener(MouseEvent.MOUSE_OUT, outBtn);
		}
		
		private function overBtn(e:MouseEvent):void 
		{
			e.target.scaleX = e.target.scaleY = 1.1;
		}
		
		private function outBtn(e:MouseEvent):void 
		{
			e.target.scaleX = e.target.scaleY = btnScale;
		}
		
		private function configPendulo():void
		{
			if (penduloClassico == null) 
			{
				penduloClassico = new PenduloClassico();
				addChild(penduloClassico);
			}
			penduloClassico.x = stage.stageWidth / 2;
			penduloClassico.y = 90;
			penduloClassico.scaleX = penduloClassico.scaleY = 1;
			penduloClassico.rotation = 0;
			
			if (pendulo == null) 
			{
				pendulo = new Pendulo();
				addChild(pendulo);
			}
			pendulo.x = stage.stageWidth / 2;
			pendulo.y = 90;
			pendulo.scaleX = pendulo.scaleY = 1;
			pendulo.rotation = 0;
			
			posPendulo = new Point(pendulo.x, pendulo.y);
		}
		
		private function setSolver():void
		{
			t = new Array(MAX_FRAMES);            // Variável independente (tempo). SOMENTE SOLUÇÃO OBTIDA COM ÊXITO.
			posX = new Array(MAX_FRAMES); // Variavel dependente (solução da EDO). SOMENTE SOLUÇÃO OBTIDA COM ÊXITO.
			
			for ( var i:int = 0; i < MAX_FRAMES; i++ ){
				t[i] = 0;
				posX[i] = new Array(pendulo.getOrder());
				for ( var j:int = 0; j < pendulo.getOrder(); j++ ) posX[i][j] = 0;
			}
			
			//O objeto solver resolve a equação diferencial definida na classe que estende ODE.
			if(solver == null) solver = new RungeKuttaCashKarpSolver(pendulo);
		}
		
		private function addListeners():void
		{
			pendulo.addEventListener("INICIANDO_ARRASTE", initArrastePendulo);
			pendulo.addEventListener("PAROU_ARRASTE", initAnimation);
			
			parametros.addEventListener("OK_PRESSED", okClicked);
			parametros.addEventListener("CANCEL_PRESSED", cancelPressed);
			
			menu.addEventListener(MouseEvent.CLICK, menuClickHndler);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, initPenduloMove);
			//stage.addEventListener(MouseEvent.MOUSE_WHEEL, changeScalePendulo);
			
			stage.addEventListener(MouseEvent.MOUSE_OVER, setInfo);
			stage.addEventListener(MouseEvent.MOUSE_OUT, setInfoOut);
			
			//stage.addEventListener(Event.ACTIVATE, flashActive);
			//stage.addEventListener(Event.DEACTIVATE, flashDeactive);
			
		}
		
		private var paused:Boolean = false;
		private var cronPused:Boolean = false;
		
		private function flashActive(e:Event = null):void 
		{
			if (paused) {
				addEventListener(Event.ENTER_FRAME, movePendulo);
				cronometer.start();
				cronoGrafico.start();
				if (cronPused) cronometro.start();
				paused = false;
			}
		}
		
		private function flashDeactive(e:Event = null):void 
		{
			if (hasEventListener(Event.ENTER_FRAME)) {
				cronometer.pause();
				cronoGrafico.pause();
				removeEventListener(Event.ENTER_FRAME, movePendulo);
				if (cronometro.isRunning()) {
					cronometro.pause();
					cronPused = true;
				}
				paused = true;
			}
		}
		
		private function setInfo(e:MouseEvent):void 
		{
			var obj:* = e.target;
			var classe:String = getQualifiedClassName(obj);
			
			//trace(classe);
			
			switch(classe) {
				case "BolaPendulo":
					setInfoMsg("Arraste o pêndulo para iniciar a animação.");
					break;
				
				case "PenduloClassicoBtn":
					setInfoMsg("Exibe/oculta o oscilador harmônico simples.");
					break;
				case "ParametrosBtn":
					setInfoMsg("Exibe/oculta as configurações da simulação.");
					break;
				case "OpenTransfer":
					setInfoMsg("Exibe/oculta o transferidor.");
					break;
				case "GraficoBtn":
					setInfoMsg("Exibe/oculta os gráficos.");
					break;
				case "CronometroBtn":
					setInfoMsg("Exibe/oculta o cronômetro.");
					break;
					
				case "AnguloInicial":
					setInfoMsg("Ângulo inicial da oscilação, em graus.");
					break;
				case "MassaOscilante":
					setInfoMsg("Massa oscilante, em quilogramas.");
					break;
				case "ComprimentoHaste":
					setInfoMsg("Comprimento da haste, em metros.");
					break;
				case "AceleracaoGravidade":
					setInfoMsg("Aceleração da gravidade, em m/s/s.");
					break;
				case "OkButton":
					setInfoMsg("Aplica os parâmetros da simulação.");
					break;
				case "CancelButton":
					setInfoMsg("Fecha tela de parâmetros da simulação.");
					break;
				
				case "TransferArraste":
					setInfoMsg("Arraste para mover o transferidor.");
					break;
				case "TransferScale":
					setInfoMsg("Arraste para aumentar ou diminuir o transferidor.");
					break;
				case "TransferTurn":
					setInfoMsg("Arraste para girar o transferidor.");
					break;
				
				case "Start":
					setInfoMsg("Inicia/pára o cronômetro.");
					break;
				case "Stop":
					setInfoMsg("Zera o cronômetro.");
					break;
					
				case "Btn_info":
					setInfoMsg("Tutorial de uso.");
					break;
				case "Btn_Instructions":
					setInfoMsg("Orientações.");
					break;
				case "Btn_Reset":
					setInfoMsg("Reiniciar.");
					break;
				case "Btn_CC":
					setInfoMsg("Créditos e licença.");
					break;
				case "BtEstatisticas":
					setInfoMsg("Desempenho.");
					break;
				
				default:
					
					break;
			}
			
		}
		
		private function setInfoOut(e:MouseEvent):void 
		{
			setInfoMsg("");
		}
		
		private function setInfoMsg(msg:String):void
		{
			infoBar.texto.text = msg;
		}
		
		private function cancelPressed(e:Event):void 
		{
			menu.parametros.gotoAndStop(1);
		}
		
		override public function reset(e:MouseEvent = null):void 
		{
			removeEventListener(Event.ENTER_FRAME, movePendulo);
			
			grafico.resetGrafico();
			parametros.initParameters();
			configPendulo();
			initVariables();
		}
		/*
		private function reset(e:MouseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, movePendulo);
			
			grafico.resetGrafico();
			parametros.initParameters();
			configPendulo();
			initVariables();
		}*/
		
		private function setGravity(g:Number):void
		{
			parametros.gravidade = g;
		}
		
		private function setTeta(teta:Number):void
		{
			parametros.teta = teta;
		}
		
		private function showHideGravidade(visivel:Boolean):void
		{
			parametros.gravidadeText.visible = visivel;
			parametros.showGravity = visivel;
		}
		
		private function showHideMHS(visivel:Boolean):void
		{
			penduloClassico.visible = visivel;
			if (visivel) menu.showHidePC.gotoAndStop(2);
			else menu.showHidePC.gotoAndStop(1);
		}
		
		private function playAnimation():void
		{
			okClicked(null);
		}
		
		private function changeScalePendulo(e:MouseEvent):void 
		{
			if (grafico.visible)
			{
				if (e.delta > 0)
				{
					grafico.redefineLimites(true);
				}
				else
				{
					grafico.redefineLimites(false);
				}
			}
			else
			{
				if (e.delta > 0)
				{
					pendulo.scaleX += 0.1;
					pendulo.scaleY += 0.1;
				}
				else
				{
					if (pendulo.scaleX > 0.1)
					{
						pendulo.scaleX -= 0.1;
						pendulo.scaleY -= 0.1;
					}
				}
				penduloClassico.scaleX = pendulo.scaleX;
				penduloClassico.scaleY = pendulo.scaleY;
			}
		}
		
		private function initPenduloMove(e:MouseEvent):void 
		{
			if (e.target is Stage)
			{
				posClick = new Point(mouseX, mouseY);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, movePenduloStage);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopMovingPendulo);
			}
		}
		
		private function movePenduloStage(e:MouseEvent):void 
		{
			pendulo.x = posPendulo.x + (mouseX - posClick.x);
			pendulo.y = posPendulo.y + (mouseY - posClick.y);
			penduloClassico.x = pendulo.x;
			penduloClassico.y = pendulo.y;
		}
		
		private function stopMovingPendulo(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movePenduloStage);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMovingPendulo);
			posPendulo = new Point(pendulo.x, pendulo.y);
			transferidor.atractors = [new Point(pendulo.x, pendulo.y)];
		}
		
		private function menuClickHndler(e:MouseEvent):void 
		{
			switch(e.target.name)
			{
				case "openTransfer":
					transferidor.rulerVisible();
					if (transferidor.visible) menu.openTransfer.gotoAndStop(2);
					else menu.openTransfer.gotoAndStop(1);
					break;
				case "cronometro":
					if (cronometro.visible) 
					{
						menu.cronometro.gotoAndStop(1);
						cronometro.visible = false;
					}
					else 
					{
						menu.cronometro.gotoAndStop(2);
						cronometro.visible = true;
					}
					break;
				case "parametros":
					if (parametros.visible == false) 
					{
						menu.parametros.gotoAndStop(2);
						parametros.openParametros();
					}
					else 
					{
						menu.parametros.gotoAndStop(1);
						parametros.visible = false;
					}
					break;
				case "grafico":
					if (menu.grafico.alpha > 0.8 )
					{
						if (grafico.visible) 
						{
							menu.grafico.gotoAndStop(1);
							grafico.visible = false;
						}
						else 
						{
							menu.grafico.gotoAndStop(2);
							grafico.visible = true;
						}
					}
					break;
				case "showHidePC":
					if (penduloClassico.visible) 
					{
						penduloClassico.visible = false;
						menu.showHidePC.gotoAndStop(2);
					}
					else
					{
						penduloClassico.visible = true;
						menu.showHidePC.gotoAndStop(1);
					}
					
					break;
				case "":
					
					break;
				
				default:
					return;
			}
		}
		
		private function okClicked(e:Event):void 
		{
			menu.parametros.gotoAndStop(1);
			mudaArray = false;
			pendulo.setG(parametros.gravidade);
			pendulo.setL(parametros.comprimento);
			grafico.resetGrafico();
			menu.grafico.alpha = 1;
			menu.grafico.filters = [];
			menu.grafico.mouseEnabled = true;
			if (parametros.teta == 0) 
			{
				menu.grafico.alpha = 0.5;
				menu.grafico.filters = [GRAYSCALE_FILTER];
				menu.grafico.mouseEnabled = false;
				removeEventListener(Event.ENTER_FRAME, movePendulo);
				pendulo.rotation = 0;
				penduloClassico.rotation = 0;
				parametros.periodo = 0;
			}
			else if (parametros.teta == 180)
			{
				menu.grafico.alpha = 0.5;
				menu.grafico.filters = [GRAYSCALE_FILTER];
				menu.grafico.mouseEnabled = false;
				removeEventListener(Event.ENTER_FRAME, movePendulo);
				pendulo.rotation = 180;
				penduloClassico.rotation = 180;
				parametros.periodo = 0;
			}
			else setMovement(parametros.teta);
		}
		
		private function initArrastePendulo(e:Event):void 
		{
			if (hasEventListener(Event.ENTER_FRAME))
			{
				removeEventListener(Event.ENTER_FRAME, movePendulo);
			}
		}
		
		private function initAnimation(e:Event):void 
		{
			mudaArray = false;
			pendulo.setG(parametros.gravidade);
			pendulo.setL(parametros.comprimento);
			grafico.resetGrafico();
			menu.grafico.alpha = 1;
			menu.grafico.filters = [];
			menu.grafico.mouseEnabled = true;
			parametros.teta = Number(pendulo.rotation.toFixed(0));
			if (parametros.teta == 0) 
			{
				menu.grafico.alpha = 0.5;
				menu.grafico.filters = [GRAYSCALE_FILTER];
				menu.grafico.mouseEnabled = false;
				removeEventListener(Event.ENTER_FRAME, movePendulo);
				pendulo.rotation = 0;
				penduloClassico.rotation = 0;
				parametros.periodo = 0;
			}
			else if (parametros.teta == 180)
			{
				menu.grafico.alpha = 0.5;
				menu.grafico.filters = [GRAYSCALE_FILTER];
				menu.grafico.mouseEnabled = false;
				removeEventListener(Event.ENTER_FRAME, movePendulo);
				pendulo.rotation = 180;
				penduloClassico.rotation = 180;
				parametros.periodo = 0;
			}
			else setMovement(parametros.teta);
		}
		
		public function setMovement(angulo:Number):void
		{
			setSolver();
			
			posArray = 0;
			// Condições iniciais.
			t[0]    = 0;
			posX[0][0] = angulo * Math.PI/180;
			posX[0][1] = 0;
			
			// Resolve a EDO para os parâmetros-padrão.
			try{
				for (var i:int = 1; i < MAX_FRAMES; i++ ) {
					
					t[i] = t[i - 1] + dt; // O próximo valor da variável independente.
					solver.evolve( t[i], posX[i], t[i - 1], posX[i - 1] ); // Reitera a solução da EDO (evolui um passo).
					//trace(t[i] + "\t" + posX[i][0] + "\t" + posX[i][1]);
				}   
			}
			catch( e:Error ){
				trace(e);
			}
			
			limpaVetorPosicoes();
			//inicioZero = true;
			//mudaArray = false;
			
			calculando.visible = false;
			calculando.gotoAndStop(1);
			cronometer.stop();
			cronometer.reset();
			cronometer.start();
			
			cronoGrafico.stop();
			cronoGrafico.reset();
			cronoGrafico.start();
			
			addEventListener(Event.ENTER_FRAME, movePendulo);
		}
		
		private function limpaVetorPosicoes():void
		{
			var cont:int = 1;
			
			var anguloIniPositivo:Boolean;
			var anguloIniPositivoAux:Boolean;
			var velIniPositivo:Boolean;
			var velIniPositivoAux:Boolean;
			var numIter:int;
			
			if (posX[0][1] != 0) 
			{
				numIter = 5;
				inicioZero = false;
				posXAux = new Array(posX.length);
				
				for (var i:int = 0; i < posX.length; i++)
				{
					posXAux[i] = posX[i];
				}
				
				for (i = 0; i < 5; i++) 
				{
					if (posXAux[cont][0] > 0) anguloIniPositivo = true;
					else anguloIniPositivo = false;
					
					if (posXAux[cont][1] > 0) velIniPositivo = true;
					else velIniPositivo = false;
					
					anguloIniPositivoAux = anguloIniPositivo;
					velIniPositivoAux = velIniPositivo;
					
					while (anguloIniPositivo == anguloIniPositivoAux && velIniPositivo == velIniPositivoAux)
					{
						if (posXAux[cont][0] > 0) anguloIniPositivoAux = true;
						else anguloIniPositivoAux = false;
						
						if (posXAux[cont][1] > 0) velIniPositivoAux = true;
						else velIniPositivoAux = false;
						
						cont++;
					}
					cont--;
					
					trace(i + " mudancaAux: " + cont);
					
					if (i == 0) 
					{
						trace(posXAux.splice(0, cont));
						cont = 0;
					}
					
				}
				posXAux.splice(cont);
				
				cont = 1;
			}
			else 
			{
				inicioZero = true;
				numIter = 4;
			}
			
			for (i = 0; i < numIter; i++)
			{
				if (posX[cont][0] > 0) anguloIniPositivo = true;
				else anguloIniPositivo = false;
				
				if (posX[cont][1] > 0) velIniPositivo = true;
				else velIniPositivo = false;
				
				anguloIniPositivoAux = anguloIniPositivo;
				velIniPositivoAux = velIniPositivo;
				
				while (anguloIniPositivo == anguloIniPositivoAux && velIniPositivo == velIniPositivoAux)
				{
					if (posX[cont][0] > 0) anguloIniPositivoAux = true;
					else anguloIniPositivoAux = false;
					
					if (posX[cont][1] > 0) velIniPositivoAux = true;
					else velIniPositivoAux = false;
					
					cont++;
				}
				cont--;
				
				if (i == 0) parametros.velocidadeMax = Math.abs(posX[cont][1]);
				//trace(parametros.velocidadeMax);
				
				//trace((i) + " mudanca: " + cont);
			}
			
			posX.splice(cont);
			t.splice(cont);
			
			
			//pendulo.setPeriodo(posX.length / 30);
			parametros.periodo = posX.length / 30;
			
		}
		
		private function movePendulo(e:Event):void 
		{
			//nAtualizacao++;
			//trace("t: " + t[posArray] + "\t" + "get: " + (getTimer() - t0) / 1000);
			var tRead:Number = cronometer.read() / 1000;
			var aux:int = posArray;
			var anguloCerto:Number = posX[posArray][0];
			//trace(t[posArray] + "\t" + anguloCerto);
			if (tRead > t[posArray])
			{
				while (tRead > t[aux] && aux < posX.length - 1)
				{
					aux++;
				}
				anguloCerto = posX[aux -1][0] + (posX[aux][0] - posX[aux -1][0]) / (t[aux] - t[aux - 1]) * (tRead - t[aux - 1]);
			}
			else
			{
				while (tRead < t[aux] && aux > 0)
				{
					aux--;
				}
				anguloCerto = posX[aux][0] + (posX[aux + 1][0] - posX[aux][0]) / (t[aux + 1] - t[aux]) * (tRead - t[aux]);
			}
			
			
			pendulo.rotation = anguloCerto * 180 / Math.PI;
			/*if (!mudaArray)*/ //pendulo.rotation = posX[posArray][0] * 180 / Math.PI;
			//else pendulo.rotation = posXAux[posArray][0] * 180 / Math.PI;
			var cronoRead:Number = cronoGrafico.read() / 1000;
			
			if (cronoRead >= 300) 
			{
				reset(null);
				//removeEventListener(Event.ENTER_FRAME, movePendulo);
				//
				//pendulo.rotation = 0;
				//penduloClassico.rotation = 0;
				//
				//cronometer.stop();
				//cronometer.reset();
				//
				//cronoGrafico.stop();
				//cronoGrafico.reset();
				//
				//cronometro.resetClock(null);
				//
				//if (grafico.visible) grafico.visible = false;
				//menu.grafico.alpha = 0.5;
			}
			
			var derivadaPhi:Number = movePenduloClassico(cronoRead) * Math.PI / 180;
			
			//if (nAtualizacao == 5)
			//{
				grafico.addPoint([cronoRead, posX[posArray][0]], [cronoRead, penduloClassico.rotation * Math.PI / 180], 
							 [posX[posArray][0], posX[posArray][1]], [penduloClassico.rotation * Math.PI / 180, derivadaPhi],
							 [cronoRead, posX[posArray][1]], [cronoRead, derivadaPhi]);
				//nAtualizacao = 0;
			//}
			
			//movePenduloClassico(t[posArray]);
			
			posArray++;
			
			if (posArray == posX.length /*&& mudaArray == false*/)
			{
				//trace(cronometer.read() / 1000);
				cronometer.reset();
				posArray = 0;
				//if (!inicioZero) mudaArray = true;
			}
			/*else if (posArray == posXAux.length && mudaArray)
			{
				trace(cronometer.read() / 1000);
				cronometer.reset();
				posArray = 0;
			}*/
		}
		
		private function movePenduloClassico(tempo:Number):Number
		{
			var w:Number = Math.sqrt(parametros.gravidade / parametros.comprimento);
			var fi:Number = Math.atan( - posX[0][1] * 180 / Math.PI / w * posX[0][0] * 180 / Math.PI);
			var A:Number = posX[0][0] * 180 / Math.PI / Math.cos(fi);
			var rotacao:Number = A * Math.cos(w * tempo + fi);
			
			penduloClassico.rotation = rotacao;
			
			return - w * A * Math.sin(w * tempo + fi);
		}
	}
	
}