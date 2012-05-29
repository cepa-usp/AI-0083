package 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class  RungeKuttaCashKarpSolver
	{
		private const EPS:Number = 1e-30;
		private const INFINITY:Number = 1e+30;    
		private const DEFAULT_ERROR:Number = 1e-3;
		private const SHRINK_EXPONENT:Number = 0.25;
		private const STRETCH_EXPONENT:Number = 0.20;
		private const MAX_SHRINK:Number = 0.1;
		private const MAX_STRETCH:Number = 4.0;
		private const SAFETY:Number = 0.9;
		
		private const DEFAULT_ITERATION_LIMIT:int = 1000;
		
		
		private const a:Array   = [    1.0/5,          3.0/10,     3.0/5,          1.0,            7.0/8       ];
		private const b:Array = [[   1.0/5,          0,          0,              0,              0           ],
								[   3.0/40,         9.0/40,     0,              0,              0           ],
								[   3.0/10,         -9.0/10,    6.0/5,          0,              0           ],
								[ -11.0/54,       5.0/2,      -70.0/27,       35.0/27,        0           ],
								[1631.0/55296,   175.0/512,  575.0/13824,    44275/110592,   253.0/4096  ]];
		private const c:Array = [   37.0/378,           0,      250.0/621,          125.0/594,              0,              512.0/1771 ];
		private const d:Array = [   -22437.0/5225472,   0,      560925.0/30046464,  -560925.0/16422912,     -277.0/14336,   277.0/7084 ];
		
		
		private var ode:ODE;
		private var error:Number;
		
		private var N:int;
		private var nCalc:int;
			

		public function RungeKuttaCashKarpSolver( ode:ODE ){
			setODE(ode);
			setError(DEFAULT_ERROR);
			setIterationLimit(DEFAULT_ITERATION_LIMIT);
		}
		//------------------------------------------------------------------------------
		// (Re)define o objeto ODE (Ordinary Differential Equation).
		//------------------------------------------------------------------------------    
		public function setODE( ode:ODE ):void{
			this.ode = ode;
		}
		//------------------------------------------------------------------------------
		// Retorna o objeto ODE (Ordinary Differential Equation).
		//------------------------------------------------------------------------------    
		public function getODE():ODE{
			return ode;
		}
		//------------------------------------------------------------------------------
		// (Re)define o valor do erro máximo aceitável [deve pertencer ao intervalo (EPS,INFINITY)].
		//------------------------------------------------------------------------------
		public function setError( error:Number ):void{
			if ( error > EPS && error < INFINITY ) this.error = error;
		}
		//------------------------------------------------------------------------------
		// Retorna o valor do erro máximo aceitável.
		//------------------------------------------------------------------------------
		public function getError():Number{
			return error;
		}    
		//------------------------------------------------------------------------------
		// (Re)define o número máximo de iterações permitidas.
		//------------------------------------------------------------------------------
		public function setIterationLimit( N:int ):void{
			if ( N > 0 ) this.N = N;
		}
		//------------------------------------------------------------------------------
		// Retorna o número máximo de iterações permitidas.
		//------------------------------------------------------------------------------    
		public function getIterationLimit():int{
			return N;
		}
		//------------------------------------------------------------------------------
		// Determina y[] (populado pelo método) em x, tomando x0 e y0[] como condições iniciais.
		//------------------------------------------------------------------------------
		public function evolve( x:Number, y:Array, x0:Number, y0:Array ):void {


			var last_y:Array  = new Array(ode.getOrder()); // Ãšltima soluÃ§Ã£o VÃ�LIDA calculada.
			var next_y:Array  = new Array(ode.getOrder()); // SoluÃ§Ã£o em cÃ¡lculo (vÃ¡lida ou nÃ£o).
			var error_y:Array = new Array(ode.getOrder()); // Erro associado a next_y[].

			var f:Array = new Array(6);// Fatores auxiliares.
			for ( var i:int = 0; i < 6; i++ ){
				f[i] = new Array(ode.getOrder());
				for( var j:int = 0; j < ode.getOrder(); j++ ){
					f[i][j] = 0;
				}
			}
			var dx:Number = (x - x0) / 10;                    // Estimativa inicial para o passo.

			//boolean crescente = ( dx > 0 );               // Identifica se x[] estÃ¡ crescente ou decrescentemente ordenado.

			var last_x:Number    = 0.0;
			var next_x:Number    = 0.0;
			var last_dx:Number   = 0.0;
			var soma:Number      = 0.0;
			var factor:Number    = 1.0;
			var dx_maximo:Number = dx;
			var exponent:Number  = SHRINK_EXPONENT;

			var i_ERROR:int = 0;

			var atribui:Boolean = false;                           // Identifica se aproximaÃ§Ã£o calculada corresponde a um elemento de x[].


			//--------------------------------------------------------------------------
			//                      >> FLUXO PRINCIPAL <<
			//--------------------------------------------------------------------------

			// Zera os erros nas soluÃ§Ãµes.
			for( i = 0; i < ode.getOrder(); i++ ) error_y[i] = 0;

			// CondiÃ§Ã£o inicial.
			last_x = x0;
			for( i = 0; i < ode.getOrder(); i++ ){
				last_y[i] = y0[i];
				//y[i][0] = last_y[i];

				next_y[i] = last_y[i];
			}

			// Inicia o cronÃ´metro.
			//time_t t = time(NULL);

			// Calcula x e *y enquanto x[0] < x < x[nPtos-1].
			nCalc = 0;
			do{

				// Contabiliza as iteraÃ§Ãµes.
				nCalc++;
				//fileOut << nCalc << "\t";

				// PrÃ³ximo valor de x.
				next_x = last_x + dx;
				//fileOut << next_x << "\t";

				// Se next_x = x (comparaÃ§Ã£o de ponto flutuante), atribui a soluÃ§Ã£o, se aprovada, ao vetor y[] e termina a execuÃ§Ã£o.
				if( Math.abs( next_x - x ) < EPS ) atribui = true;
				else atribui = false;

				/*
				 * ---------------------------------------------------------------------------------------
				 * Uma vez definido qual serÃ¡ o prÃ³ximo ponto a resolver, procede a integraÃ§Ã£o: calcula...
				 * a) ... os fatores de Cash-Karp;
				 * b) ... next_y[ordem-1], next_y[ordem-2], ..., next_y[0] nesta seqÃ¼Ãªncia;
				 * c) ... os erros cometidos.
				 * ---------------------------------------------------------------------------------------
				 */

				// a) ... os fatores de Cash-Karp.
				if( ode.getOrder() > 1 ){
					for( i = 0; i <= ode.getOrder()-2; i++ ){
						f[0][i] = last_y[i+1];
						checkOverflow( f[0][i] );
					}
				}

				f[0][ode.getOrder()-1] = ode.F( last_x, last_y );
				checkOverflow( f[0][ode.getOrder()-1] );

				for( var n:int = 1; n <= 5; n++ ){
					for( i = ode.getOrder()-1; i >= 0; i-- ){

						soma = 0;
						for( j = 0; j <= n-1; j++ ){
							soma += b[n-1][j] * f[j][i];
							checkOverflow( soma );
						}

						next_y[i] = last_y[i] + soma * dx;
						checkOverflow( next_y[i] );
					}

					if( ode.getOrder() > 1 ){
						for( i = 0; i <= ode.getOrder()-2; i++ ){
							f[n][i] = next_y[i+1];
							checkOverflow( f[n][i] );
						}
					}

					f[n][ode.getOrder()-1] = ode.F( last_x + a[n-1]*dx, next_y );
					checkOverflow( f[n][ode.getOrder()-1] );
				}

				// b) ... next_y[ordem-1], next_y[ordem-2], ..., next_y[0] nesta seqÃ¼Ãªncia.
				// c) ... os erros cometidos.
				for( i = 0; i < ode.getOrder(); i++ ){

					next_y[i] = error_y[i] = 0;

					for( j = 0; j <= 5; j++ ){
						next_y[i]  += c[j] * f[j][i];
						checkOverflow( next_y[i] );

						error_y[i] += d[j] * f[j][i];
						checkOverflow( error_y[i] );
					}

					next_y[i] = last_y[i] + next_y[i] * dx;
					checkOverflow( next_y[i] );

					// Seleciona o maior erro cometido na aproximaÃ§Ã£o acima.
					if( Math.abs(error_y[i]) > Math.abs(error_y[i_ERROR]) ) i_ERROR = i;
				}

				error_y[i_ERROR] = Math.abs(error_y[i_ERROR]);

				/*
				 * -----------------------------------------------------
				 * Calculada a soluÃ§Ã£o de quinta ordem, aprova-a ou nÃ£o:
				 * a) compara o erro obtido com o exigido;
				 * b) se aprovada, ...
				 *   b.1) ... escolhe a potÃªncia apropriada para correÃ§Ã£o de dx;
				 *   b.2) ... redefine o Ãºltimo ponto vÃ¡lido calculado (last_x e last_y);
				 *   b.3) ... se o ponto calculado for um de satisfaÃ§Ã£o, ...
				 *     b.3.i)  ... atribui os valores encontrados ao vetor de satisfaÃ§Ã£o (**y);
				 *     b.3.ii) ... incrementa o ponto de satisfaÃ§Ã£o;
				 * c) se reprovada, ...
				 *   c.1) ... escolhe a potÃªncia apropriada para a correÃ§Ã£o de dx.
				 * -----------------------------------------------------
				 */
				if( error_y[i_ERROR] <= error ){

					exponent = STRETCH_EXPONENT;

					// Valida a aproximaÃ§Ã£o recÃ©m-calculada (move-se para o prÃ³ximo ponto).
					last_x = next_x;
					for( i = 0; i < ode.getOrder(); i++ ){
						last_y[i] = next_y[i];
					}

					// Atribui a soluÃ§Ã£o recÃ©m-calculada a y[].
					if( atribui ){
						for( i = 0; i < ode.getOrder(); i++ ) y[i] = last_y[i];                    
					}
				}
				else{
					exponent = SHRINK_EXPONENT;
				}

				/*
				 * ---------------------------------
				 * Define dx para o prÃ³ximo ponto.
				 * ---------------------------------
				 */
				last_dx = dx;

				dx_maximo = x - last_x;
				if ( Math.abs(dx_maximo) > INFINITY ) dx_maximo = INFINITY;
				else if( Math.abs(dx_maximo) < EPS ) dx_maximo = EPS;

				if( error_y[i_ERROR] < EPS ){
					dx = dx_maximo;
				}
				else{
					factor = SAFETY * Math.pow( error/error_y[i_ERROR], exponent );
					if( factor > MAX_STRETCH ) factor = MAX_STRETCH;
					else if( factor < MAX_SHRINK ) factor = MAX_SHRINK;

					dx = factor * last_dx;
					if( Math.abs(dx) > dx_maximo) dx = dx_maximo;
					else if( Math.abs(dx) < EPS) dx = EPS;
				}

				// Impede que a integraÃ§Ã£o leve mais tempo que timeout.
			/*
				if( this->hasTimeout && difftime(time(NULL),t) > this->timeout ){
					throw TimeoutException();
				}*/

			}while( !atribui );

			//System.out.println( "IteraÃ§Ãµes: " + nCalc );
		}

		//------------------------------------------------------------------------------
		private function checkOverflow( number:Number ):void {
			if ( Math.abs(number) > INFINITY ){
				//throw new Exception();
				throw new Error("Shit happens");
				
			}
		}

	}
	
}