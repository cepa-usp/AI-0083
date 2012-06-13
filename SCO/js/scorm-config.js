var learnername = ""; // Nome do aluno
var completed = false; // Status da AI: completada ou não
var score = 0; // Nota do aluno (de 0 a 100)
var scormExercise = 1; // Exercício corrente relevante ao SCORM
var screenExercise = 1; // Exercício atualmente visto pelo aluno (não tem relação com scormExercise)
var N_EXERCISES = 10; // Quantidade de exercícios desta AI
var scorm = pipwerks.SCORM; // Seção SCORM
scorm.version = "2004"; // Versão da API SCORM
var PING_INTERVAL = 5 * 60 * 1000; // milissegundos
var pingCount = 0; // Conta a quantidade de pings enviados para o LMS
var ai; // Referência para a AI (Flash)
var MAX_INIT_TRIES = 60;
var init_tries = 0;
var debug = true;
var SCORE_UNIT = 5.55;
var currentScore = 0;
var exOk;

$(document).ready(init); // Inicia a AI.
$(window).unload(uninit); // Encerra a AI.


/*
 * Inicia a Atividade Interativa (AI)
 */
function init () {
  configAi();
  checkCallbacks();
}
  
/*
 * Encerra a Atividade Interativa (AI)
 */ 
function uninit () {
  if (!completed) {
    save2LMS();
    scorm.quit();
  }
}  
  
function configAi () {
	
	var flashvars = {};
	flashvars.ai = "swf/AI-0083.swf";
	flashvars.width = "700";
	flashvars.height = "500";
	flashvars.disable = "RESET_BUTTON,TUTORIAL_BUTTON";
		
	var params = {};
	params.menu = "false";
	params.scale = "noscale";

	var attributes = {};
	attributes.id = "ai";
	attributes.align = "middle";
	

	swfobject.embedSWF("swf/AI-0083.swf", "ai-container", flashvars.width, flashvars.height, "10.0.0", "expressInstall.swf", flashvars, params, attributes);
	
  //Deixa a aba "Orientações" ativa no carregamento da atividade
  $('#exercicios').tabs({ selected: 0 });
  
  // Configurações dos botões em geral
  $('.check-button').button().click(evaluateExercise);
  $('.check-button2').button().click(evaluateExercise);
  $('.check-button3').button().click(evaluateExercise);
  $('.check-button4').button().click(evaluateExercise);
  $('.check-button5').button().click(evaluateExercise);
  $('.check-button6').button().click(evaluateExercise);
  $('.check-button7').button().click(evaluateExercise);
  $('.check-button8').button().click(evaluateExercise);
  $('.check-button9').button().click(evaluateExercise);
  $('.check-button10').button().click(evaluateExercise);

  //Começa com botão Terminar desabilitado.
  $( ".check-button" ).button({ disabled: true });
  $( ".check-button2" ).button({ disabled: true });
  $( ".check-button3" ).button({ disabled: true });
  $( ".check-button4" ).button({ disabled: true });
  $( ".check-button5" ).button({ disabled: true });
  $('.check-button6').button({ disabled: true });
  $('.check-button7').button({ disabled: true });
  $('.check-button8').button({ disabled: true });
  $('.check-button9').button({ disabled: true });
  $('.check-button10').button({ disabled: true }); 
 
  
  //(Re)abilita os exercícios já feitos e desabilita aqueles ainda por fazer.
  if (completed) $('#exercicios').tabs("option", "disabled", []);
  else {
    for (i = 0; i <= N_EXERCISES; i++) {
      if (i <= scormExercise) $('#exercicios').tabs("enable", i);
      else $('#exercicios').tabs("disable", i);
    }
  }
  
  // Posiciona o aluno no exercício da vez
  screenExercise = scormExercise;
  $('#exercicios').tabs("select", scormExercise - 1);
  
}

function selectExercise (exercise) {
	switch(exercise) {
		case 1:
			console.log("Configurando o exercício 1");
			

			break;
			
		case 2:
			console.log("Configurando o exercício 2");
			
	
	
			break;
			
		case 3:
			console.log("Configurando o exercício 3");

			
			break;
			
		case 4:
			console.log("Configurando o exercício 4");
			ai.setTeta(10);
            ai.playAnimation();

			break;
			
		case 5:
			console.log("Configurando o exercício 5");

			break;
		
		case 6:
			console.log("Configurando o exercício 6");
			

			break;
			
		case 7:
			console.log("Configurando o exercício 7");
			

			break;
			
		case 8:
			console.log("Configurando o exercício 8");
			console.log(ai.getPeriodo());

			break;
			
		case 9:
			console.log("Configurando o exercício 9");
			

			break;
			
		case 10:
			console.log("Configurando o exercício 10");
			

			break;
			
		default:
			console.log("Ops! Isto não devia tera acontecido!");
			break;
	}
}


function checkCallbacks () {
	var t2 = new Date().getTime();
	ai = document.getElementById("ai");
	var exOk = false;
	try {
		ai.doNothing();
		message("swf ok!");
		exOk = true;
	}
	catch(error) {
		++init_tries;
		
		if (init_tries > MAX_INIT_TRIES) {
			alert("Carregamento falhou.");
		}
		else {
			message("falhou");
			setTimeout("checkCallbacks()", 1000);
		}
	}
	
	if(exOk) iniciaAtividade();
}


function getAi(){
	ai = document.getElementById("ai");
	iniciaAtividade();
}

// Inicia a AI.
function iniciaAtividade(){       
  
   // Habilita/desabilita a visualização da mediatriz
  $('#exercicios').tabs({
    select: function(event, ui) {
    
      screenExercise = ui.index;  
	  ai.showHideMHS(false);
        
        if (screenExercise == 6) {
          ai.showHideGravidade(true);
          
          if (Math.abs(ai.getTeta() - 10) < 1) {
            ai.setTeta(10);
            ai.playAnimation();
          }
        }
        else if (screenExercise == 10) {
          ai.setTeta(10);
          ai.setGravity(22.9);
          ai.showHideGravidade(false);
          ai.playAnimation();
        }
        else {
          ai.showHideGravidade(true);
        }
	  
	selectExercise(screenExercise);
	  
    }
  });

  //Textfields aceitam apenas número, ponto e vírgula.
  $('input').keyup(function(e) {
    var a = [];
    var k = e.which;
	    
    for (i = 44; i < 58; i++)
        a.push(i);

    if (!(a.indexOf(k)>=0))
        e.preventDefault();
	
	//Declaração de variaveis.
	var value01 = $("input[type=text][id=p_oscilacao]").val();
	var value02 = $("input[type=text][id=p_calculado]").val();
	var value03 = $("input[type=text][id=e_maximo]").val();
	var value04 = $("input[type=text][id=a_angulos]").val();
	var value05 = $("input[type=text][id=o_angulos]").val();
	var value06 = $("input[type=text][id=f_angulos]").val();
	var value07 = $("input[type=text][id=d_theta]").val();
	var value08 = $("input[type=text][id=v_linear]").val();
	var value09 = $("input[type=text][id=m_theta]").val();
	var value10 = $("input[type=text][id=mx_angular]").val();
	var value11 = $("input[type=text][id=a_peq]").val();
	var value12 = $("input[type=text][id=oa_peq]").val();
	var value13 = $("input[type=text][id=fa_peq]").val();
	var value14 = $("input[type=text][id=pa_g]").val();
	var value15 = $("input[type=text][id=err_max]").val();
	var value16 = $("input[type=text][id=planeta]").val();
	
	//Habilitar Próximo
	if(screenExercise == 1) {
		if(value01 != '') {
		    //Habilita botão Terminei no exercicio 1.
			$( ".check-button" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 2) {
		if(value02 != '') {
		    //Habilita botão Terminei no exercicio 2.
			$( ".check-button2" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 3) {
		if(value03 != '') {
		    //Habilita botão Terminei no exercicio 3.
			$( ".check-button3" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 4) {
		if(value04 != '' && value05 != '' && value06 != '') {
		    //Habilita botão Terminei no exercicio 4.
			$( ".check-button4" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 5) {
		if(value07 != '' && value08 != '') {
		    //Habilita botão Terminei no exercicio 5.
			$( ".check-button5" ).button({ disabled: false });
	    }
	}

	if(screenExercise == 6) {
		if(value09 != '' && value10 != '') {
		    //Habilita botão Terminei no exercicio 6.
			$( ".check-button6" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 7) {
		if(value11 != '' && value12 != '' && value13 != '') {
		    //Habilita botão Terminei no exercicio 7.
			$( ".check-button7" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 8) {
		if(value14 != '') {
		    //Habilita botão Terminei no exercicio 8.
			$( ".check-button8" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 9) {
		if(value15 != '') {
		    //Habilita botão Terminei no exercicio 9.
			$( ".check-button9" ).button({ disabled: false });
	    }
	}
	if(screenExercise == 10) {
		if(value16 != '') {
		    //Habilita botão Terminei no exercicio 10.
			$( ".check-button10" ).button({ disabled: false });
	    }
	}	
	
  });
  
  initAI();
  
}

/*
 * Inicia a conexão SCORM.
 */ 
function initAI () {
 
  // Conecta-se ao LMS
  var connected = scorm.init();
  
  // A tentativa de conexão com o LMS foi bem sucedida.
  if (connected) {
  
    // Verifica se a AI já foi concluída.
    var completionstatus = scorm.get("cmi.completion_status");
    
    // A AI já foi concluída.
    switch (completionstatus) {
    
      // Primeiro acesso à AI
      case "not attempted":
      case "unknown":
      default:
        completed = false;
        learnername = scorm.get("cmi.learner_name");
        scormExercise = 1;
        score = 0;
        
        $("#completion-message").removeClass().addClass("completion-message-off");    
        break;
        
      // Continuando a AI...
      case "incomplete":
        completed = false;
        learnername = scorm.get("cmi.learner_name");
        scormExercise = parseInt(scorm.get("cmi.location"));
        score = parseInt(scorm.get("cmi.score.raw"));
        
        $("#completion-message").removeClass().addClass("completion-message-off");
        break;
        
      // A AI já foi completada.
      case "completed":
        completed = true;
        learnername = scorm.get("cmi.learner_name");
        scormExercise = parseInt(scorm.get("cmi.location"));
        score = parseInt(scorm.get("cmi.score.raw"));
        
        $("#completion-message").removeClass().addClass("completion-message-on");
        break;
    }
    
    if (isNaN(scormExercise)) scormExercise = 1;
    if (isNaN(score)) score = 0;
 
	scorm.set("cmi.score.min", 0);
	scorm.set("cmi.score.max", 100);
    
    // Posiciona o aluno no exercício da vez
    screenExercise = scormExercise;
    $('#exercicios').tabs("select", scormExercise - 1); 
	
    pingLMS();
    
  }
  // A tentativa de conexão com o LMS falhou.
  else {
    completed = false;
    learnername = "";
    scormExercise = 1;
    score = 0;
    log.error("A conexão com o Moodle falhou.");
  }
}

/*
 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
 */ 
function save2LMS () {
  if (scorm.connection.isActive) {
  
    // Salva no LMS a nota do aluno.
	
    var success = scorm.set("cmi.score.raw", Math.round(score));
  
    // Notifica o LMS que esta atividade foi concluída.
    success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));
	
	if (completed) {
		scorm.set("cmi.exit", "normal");
	} else { 
		scorm.set("cmi.exit","suspend");
	}
    
	success = scorm.set("cmi.success_status", (score > 75 ? "passed" : "failed"));
	
    // Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
    success = scorm.set("cmi.location", scormExercise);
    
    if (!success) log.error("Falha ao enviar dados para o LMS.");
  }
  else {
    log.trace("A conexão com o LMS não está ativa.");
  }
}

/*
 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
 */
function pingLMS () {

	scorm.get("cmi.completion_status");
	var timer = setTimeout("pingLMS()", PING_INTERVAL);
}

/*
 * Avalia a resposta do aluno ao exercício atual. Esta função é executada sempre que ele pressiona "terminei".
 */ 
function evaluateExercise (event) {
   
  // Avalia a nota
  var currentScore = getScore(screenExercise);
  score += (currentScore / N_EXERCISES)/2;
  
  if(exOk == false) return;
  console.log(screenExercise + "\t" + currentScore);
  // Mostra a mensagem de erro/acerto
  feedback(screenExercise, currentScore);
 
  // Atualiza a nota do LMS (apenas se a questão respondida é aquela esperada pelo LMS)
  if (!completed && screenExercise == scormExercise) {
    
    if (scormExercise < N_EXERCISES) {
      nextExercise();
    }
    else {
		score += 50;
		score = Math.round(score);
      completed = true;
      scormExercise = 1;
      save2LMS();
      scorm.quit();
	
    }
  } 
}

/*
 * Prepara o próximo exercício.
 */ 
function nextExercise () {
  if (scormExercise < N_EXERCISES) ++scormExercise;
  
  $('#exercicios').tabs("enable", scormExercise);
}

var TOLERANCE = 0.10;

function evaluate (user_answer, right_answer, tolerance) {
	return Math.abs(user_answer - right_answer) <= tolerance * Math.abs(right_answer);
}

/*
 * Avalia a nota do aluno num dado exercício.
 */ 
function getScore (exercise) {

  ans = 0;
  exOk = true;
  switch (exercise) {
  
    // Avalia a nota do exercício 1
    case 1:
    default: 
		var user_answer_1 = Math.abs(ai.getTeta());
		var right_answer_1 = 10;
		var user_answer_2 = parseFloat($("#p_oscilacao").val().replace(",","."));
		var right_answer_2 = ai.getPeriodo();
		
		//Valores em branco?
		var value01 = $("input[type=text][id=p_oscilacao]").val();
		if (value01 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}	  
	  
	    //Desabilita caixa de resposta e botão Terminei.
	  	$( "#p_oscilacao" ).attr("disabled",true);
		$( ".check-button" ).button({ disabled: true });
	
		if (Math.abs(user_answer_1 - right_answer_1) <= 2 ) {
			ans += 100/2;
		}
		else {
			ai.setTeta(10);
			ai.playAnimation();
            var right_answer_2 = ai.getPeriodo(); 		
			var user_answer_2 = parseFloat($("#p_oscilacao").val().replace(",","."));		
			var right_answer_2 = ai.getPeriodo();			
			$('#message1b').html('A amplitude deveria ser de 10º (já foi corrigida).').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_2, right_answer_2, TOLERANCE)) {
			ans += 100/2;
			$("#p_oscilacao").css("background-color", "#66CC33");
		}
		else {
			$("#p_oscilacao").css("background-color", "#FA5858");
			$('#message1a').html('O período correto é ' + right_answer_2.toFixed(1).replace(".",",") + ' s.').removeClass().addClass("wrong-answer");
		}
		
		ans = Math.round(ans);
		
	break;	
		
    // Avalia a nota do ex2
	case 2:
	    
		var user_answer = parseFloat($("#p_calculado").val().replace(",","."));
		var right_answer = 2 * Math.PI * Math.sqrt(ai.getComprimento() / ai.getGravidade());
		
		//Valores em branco?
		var value01 = $("input[type=text][id=p_calculado]").val();
		if (value01 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}	 

		//Desabilita caixa de resposta e botão Terminei.
		$( "#p_calculado" ).attr("disabled",true);
		$( ".check-button2" ).button({ disabled: true });
	  
		if (evaluate(user_answer, right_answer, TOLERANCE)) {
			ans += 100;
			$("#p_calculado").css("background-color", "#66CC33");
		}
		else {
			$("#p_calculado").css("background-color", "#FA5858");
		}
		
		ans = Math.round(ans);
	  
	break;
		
	// Avalia a nota do ex3
	case 3:
	
		var small_angle = 10 * Math.PI / 180
		var user_answer = parseFloat($("#e_maximo").val().replace(",","."));
		var right_answer = Math.abs(Math.sin(small_angle) - small_angle);
		//console.log('resp_user:' + user_answer);
		//console.log('resp_certa:' + right_answer);
 		
		//Valores em branco?
		var value01 = $("input[type=text][id=e_maximo]").val();
		if (value01 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}	 
	    //Desabilita caixa de resposta e botão Terminei.
		$( "#e_maximo" ).attr("disabled",true);
		$( ".check-button3" ).button({ disabled: true });
	  
		//questao 3 mudei tolerancia pq senao o usuario nunca acertaria digitando 0,0009
		if (evaluate(user_answer, right_answer, TOLERANCE)) {
			ans += 100;
			$("#e_maximo").css("background-color", "#66CC33");
		}
		else {
			$("#e_maximo").css("background-color", "#FA5858");
		}
		
		ans = Math.round(ans);

	break;
		
	// Avalia a nota do ex4
	case 4:
	  
		var user_answer_1 = parseFloat($("#a_angulos").val().replace(",","."));
		var right_answer_1 = Math.abs(ai.getTeta() * Math.PI / 180);	
		var user_answer_2 = parseFloat($("#o_angulos").val().replace(",","."));
		var right_answer_2 = Math.sqrt(ai.getGravidade() / ai.getComprimento());
		var user_answer_3 = parseFloat($("#f_angulos").val().replace(",","."));
		var right_answer_3 = 0;
        
		//Valores em branco?
		var value01 = $("input[type=text][id=a_angulos]").val();
		var value02 = $("input[type=text][id=o_angulos]").val();
		var value03 = $("input[type=text][id=f_angulos]").val();
		if (value01 == '' || value02 == '' || value03 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}	 
		
		//Desabilita caixa de resposta e botão Terminei.
		$( "#a_angulos" ).attr("disabled",true);
		$( "#o_angulos" ).attr("disabled",true);
		$( "#f_angulos" ).attr("disabled",true);
		$( ".check-button4" ).button({ disabled: true });
		
		if (evaluate(user_answer_1, right_answer_1, TOLERANCE)) {
			ans += 100/3;
			$("#a_angulos").css("background-color", "#66CC33");
		}
		else {
			$("#a_angulos").css("background-color", "#FA5858");
			$('#message4a').html('A amplitude (A) correta é ' + right_answer_1.toFixed(2).replace(".",",") + ' rad.').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_2, right_answer_2, TOLERANCE)) {
			ans += 100/3;
			$("#o_angulos").css("background-color", "#66CC33");
		}
		else {
			$("#o_angulos").css("background-color", "#FA5858");
			$('#message4b').html('O &omega; correto é ' + right_answer_2.toFixed(2).replace(".",",") + ' rad/s.').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_3, right_answer_3, TOLERANCE)) {
			ans += 100/3;
			$("#f_angulos").css("background-color", "#66CC33");
		}
		else {
			$("#f_angulos").css("background-color", "#FA5858");
			$('#message4c').html('A fase (&phi;) correta é ' + right_answer_3.toFixed(0).replace(".",",") + ' rad.').removeClass().addClass("wrong-answer");
		}
		
		ans = Math.round(ans);

	break;
		
	// Avalia a nota do ex5
	case 5:
	  
		var user_answer_1 = parseFloat($("#d_theta").val().replace(",","."));
		var right_answer_1 = Math.sqrt(ai.getGravidade() / ai.getComprimento()) * (ai.getTeta() * Math.PI / 180);
		var user_answer_2 = parseFloat($("#v_linear").val().replace(",","."));
		var right_answer_2 = right_answer_1 * ai.getComprimento();
		
		//Valores em branco?
		var value01 = $("input[type=text][id=d_theta]").val();
		var value02 = $("input[type=text][id=v_linear]").val();
		if (value01 == '' || value02 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}	
		
		//Desabilita caixa de resposta e botão Terminei.
		$( "#d_theta" ).attr("disabled",true);
		$( "#v_linear" ).attr("disabled",true);
		$( ".check-button5" ).button({ disabled: true });
            
		if (evaluate(user_answer_1, right_answer_1, TOLERANCE)) {
			ans += 100/2;
			$("#d_theta").css("background-color", "#66CC33");
		}
		else {
			$("#d_theta").css("background-color", "#FA5858");
			$('#message5a').html('A velocidade angular correta é ' + right_answer_1.toFixed(2).replace(".",",") + ' rad/s.').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_2, right_answer_2, TOLERANCE)) {
			ans += 100/2;
			$("#v_linear").css("background-color", "#66CC33");
		}
		else {
			$("#v_linear").css("background-color", "#FA5858");
			$('#message5b').html('A velocidade linear correta é ' + right_answer_2.toFixed(2).replace(".",",") + ' m/s.').removeClass().addClass("wrong-answer");
		}
	  
	    ans = Math.round(ans);
	   	  	  	    
	break;
		
	// Avalia a nota do ex6
	case 6:
		
		var user_answer_1 = parseFloat($("#m_theta").val().replace(",","."));
		var right_answer_1 = Math.abs(ai.getTeta()) * Math.PI / 180;
		var user_answer_2 = parseFloat($("#mx_angular").val().replace(",","."));
		var right_answer_2 = ai.getVelocidade();
		
		//Valores em branco?
		var value01 = $("input[type=text][id=m_theta]").val();
		var value02 = $("input[type=text][id=mx_angular]").val();
		if (value01 == '' || value02 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}

		//Desabilita caixa de resposta e botão Terminei.
		$( "#m_theta" ).attr("disabled",true);
		$( "#mx_angular" ).attr("disabled",true);
		$( ".check-button6" ).button({ disabled: true });
            
		if (evaluate(user_answer_1, right_answer_1, TOLERANCE)) {
			ans += 100/2;
			$("#m_theta").css("background-color", "#66CC33");
		}
		else {
			$("#m_theta").css("background-color", "#FA5858");
			$('#message6a').html('O ângulo correto é ' + right_answer_1.toFixed(2).replace(".",",") + ' rad/s.').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_2, right_answer_2, TOLERANCE)) {
			ans += 100/2;
			$("#mx_angular").css("background-color", "#66CC33");
		}
		else {
			$("#mx_angular").css("background-color", "#FA5858");
			$('#message6b').html('A velocidade angular correta é ' + right_answer_2.toFixed(2).replace(".",",") + ' m/s.').removeClass().addClass("wrong-answer");
		}
	  
	    ans = Math.round(ans);
      		
	break;
	  
	// Avalia a nota do ex7
	case 7:
		/* theta(t) = A cos(omega t + phi) */
		var right_answer_2 = Math.sqrt(ai.getGravidade() / ai.getComprimento()); /* omega */
		var right_answer_3 = Math.atan(-3 / (5 * right_answer_2)); /* phi */
		var user_answer_1 = parseFloat($("#a_peq").val().replace(",","."));
		var right_answer_1 = (5 * Math.PI / 180) / Math.cos(right_answer_3) /* A */
		var user_answer_2 = parseFloat($("#oa_peq").val().replace(",","."));
		var user_answer_3 = parseFloat($("#fa_peq").val().replace(",",".")); 
		//console.log(right_answer_2);
		
		//Valores em branco?
		var value01 = $("input[type=text][id=a_peq]").val();
		var value02 = $("input[type=text][id=oa_peq]").val();
		var value03 = $("input[type=text][id=fa_peq]").val();
		if (value01 == '' || value02 == '' || value03 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}		
	      
		//Desabilita caixa de resposta e botão Terminei.
		$( "#a_peq" ).attr("disabled",true);
		$( "#oa_peq" ).attr("disabled",true);
		$( "#fa_peq" ).attr("disabled",true);
		$( ".check-button7" ).button({ disabled: true });
            
		if (evaluate(user_answer_1, right_answer_1, TOLERANCE)) {
			ans += 100/3;
			$("#a_peq").css("background-color", "#66CC33");
		}
		else {
			$("#a_peq").css("background-color", "#FA5858");
			$('#message7a').html('A amplitude correta é ' + right_answer_1.toFixed(2).replace(".",",") + ' rad/s.').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_2, right_answer_2, TOLERANCE)) {
			ans += 100/3;
			$("#oa_peq").css("background-color", "#66CC33");
		}
		else {
			$("#oa_peq").css("background-color", "#FA5858");
			$('#message7b').html('A velocidade angular correta é ' + right_answer_2.toFixed(2).replace(".",",") + ' m/s.').removeClass().addClass("wrong-answer");
		}
		if (evaluate(user_answer_3, right_answer_3, TOLERANCE)) {
			ans += 100/3;
			$("#fa_peq").css("background-color", "#66CC33");
		}
		else {
			$("#fa_peq").css("background-color", "#FA5858");
			$('#message7c').html('A fase correta é ' + right_answer_3.toFixed(2).replace(".",",") + ' m/s.').removeClass().addClass("wrong-answer");
		}
		
	    ans = Math.round(ans); 
  	  
	break;
	  
	// Avalia a nota do ex8
	case 8:
		var user_answer_1 = Math.abs(ai.getTeta());
		var right_answer_1 = 90;
		var user_answer_2 = parseFloat($("#pa_g").val().replace(",","."));
		

		//Valores em branco?
		var value01 = $("input[type=text][id=pa_g]").val();
		if (value01 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}
		
		//Desabilita caixa de resposta e botão Terminei.
		$( "#pa_g" ).attr("disabled",true);
		$( ".check-button8" ).button({ disabled: true });
            
		if (Math.abs(user_answer_1 - right_answer_1) <= 2 ) {
			ans += 100/2;
		}
		else {
		    ai.setTeta(90);
			ai.playAnimation();
			$('#message8a').html('A amplitude deveria ser de 90º (já foi corrigida).').removeClass().addClass("wrong-answer");
		}
		var right_answer_2 = ai.getPeriodo();
		if (evaluate(user_answer_2, right_answer_2, TOLERANCE)) {
			ans += 100/2;
			$("#pa_g").css("background-color", "#66CC33");
		}
		else {
			$("#pa_g").css("background-color", "#FA5858");
			$('#message8b').html('O período correto é ' + right_answer_2.toFixed(2).replace(".",",") + ' m/s.').removeClass().addClass("wrong-answer");
		}		
	  
	break;
	  
	// Avalia a nota do ex9
	case 9:
	    var big_angle = 90 * Math.PI / 180
		var small_angle = 10 * Math.PI / 180;
		var user_answer = parseFloat($("#err_max").val().replace(",","."));
		var right_answer = Math.abs(Math.sin(big_angle) - big_angle) / Math.abs(Math.sin(small_angle) - small_angle);

		//Valores em branco?
		var value01 = $("input[type=text][id=err_max]").val();
		if (value01 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		}		
		
		//Desabilita caixa de resposta e botão Terminei.
		$( "#err_max" ).attr("disabled",true);
		$( ".check-button9" ).button({ disabled: true });
            
		if (evaluate(user_answer, right_answer, TOLERANCE)) {
			ans += 100;
			$("#err_max").css("background-color", "#66CC33");
		}
		else {
			$("#err_max").css("background-color", "#FA5858");
		}		
        
		ans = Math.round(ans);
	  
    break;
	  
	// Avalia a nota do ex10
	case 10:
		var user_answer = $("#planeta").val();
		var right_answer = "Júpiter";
		var succeeds = levenshteinDistance(user_answer.toLowerCase(), right_answer.toLowerCase()) < 2;
 
		//Valores em branco?
		var value01 = $("input[type=text][id=planeta]").val();
		if (value01 == ''){ 
			alert('Preencher todos os campos!');
			exOk = false;
			return;
		} 
 
		//Desabilita caixa de resposta e botão Terminei.
		$( "#planeta" ).attr("disabled",true);
		$( ".check-button10" ).button({ disabled: true });
            
		if (succeeds){
			ans += 100;
			$("#planeta").css("background-color", "#66CC33");
		}
		else {
			$("#planeta").css("background-color", "#FA5858");
		}		
        
		ans = Math.round(ans); 
	  
	break;

    }
  return ans;
}

/*
 * Exibe a mensagem de erro/acerto (feedback) do aluno para um dado exercício e nota (naquele exercício).
 */ 
function feedback (exercise, score) {
                       
  switch (exercise) {

    // Feedback da resposta ao exercício 1
    case 1:		
		if (score == 100) {
			$('#message1a').html('Resposta correta!').removeClass().addClass("right-answer");
		} 
		
    break;
    
    // Feedback da resposta ao exercício 2
    case 2:
		if (score == 100) {
			$('#message2').html('Resposta correta!').removeClass().addClass("right-answer");
		} else {			
			var right_answer = 2 * Math.PI * Math.sqrt(ai.getComprimento() / ai.getGravidade());	  
			$('#message2').html('O período correto é ' + right_answer.toFixed(1).replace(".",",") + ' s.').removeClass().addClass("wrong-answer");
		}
	  
    break;
	  
    // Feedback da resposta ao exercício 3
    case 3:
		if (score == 100) {
			$('#message3').html('Resposta correta!').removeClass().addClass("right-answer");
		} else {
			var small_angle = 10 * Math.PI / 180
			var right_answer = Math.abs(Math.sin(small_angle) - small_angle);
			$('#message3').html('O erro máximo é ' + right_answer.toFixed(4).replace(".",",") + ' rad.').removeClass().addClass("wrong-answer");
		}
      
    break;	  

    // Feedback da resposta ao exercício 4
    case 4:
		if (score == 100) {
			$('#message4a').html('Resposta correta!').removeClass().addClass("right-answer");
		}
	
    break;
	  
    // Feedback da resposta ao exercício 5
    case 5:   	
		if (score == 100) {
			$('#message5a').html('Resposta correta!').removeClass().addClass("right-answer");
		}
	   
    break;
	  
    // Feedback da resposta ao exercício 6
    case 6:
		if (score == 100) {
			$('#message6a').html('Resposta correta!').removeClass().addClass("right-answer");
		}
      
    break;
	  
	// Feedback da resposta ao exercício 7
    case 7:
		if (score == 100) {
			$('#message7a').html('Resposta correta!').removeClass().addClass("right-answer");
		}
      
    break;
	
    // Feedback da resposta ao exercício 8
    case 8:
		if (score == 100) {
			$('#message8a').html('Resposta correta!').removeClass().addClass("right-answer");
		}
		      
    break;
	
    // Feedback da resposta ao exercício 9
    case 9:
		if (score == 100) {
			$('#message9').html('Resposta correta!').removeClass().addClass("right-answer");
		} else {
			var big_angle = 90 * Math.PI / 180;
			var small_angle = 10 * Math.PI / 180;
			var right_answer = Math.abs(Math.sin(big_angle) - big_angle) / Math.abs(Math.sin(small_angle) - small_angle);
			$('#message9').html('O erro para a oscilação de 90º é ' + Math.round(right_answer) + ' vezes maior que para a oscilação de 10º.').removeClass().addClass("wrong-answer");
		}
      
    break;	
	
    // Feedback da resposta ao exercício 10
    case 10:
		if (score == 100) {
			$('#message10').html('Resposta correta!').removeClass().addClass("right-answer");
		} else {
			var right_answer = "Júpiter";
			$('#message10').html('O planeta correto é ' + right_answer + '.').removeClass().addClass("wrong-answer");
		}

    break;
	
  }
}


/*
 * Retorna a distância de Levenshtein entre duas Strings.
 */
function levenshteinDistance (string1, string2) {

	string1 = (string1 != null ? string1 : "");
	string2 = (string2 != null ? string2 : "");
	
	if (string1 == string2) return 0;

	var d = new Array();
	var cost;
	var i;
	var j;
	var n = string1.length;
	var m = string2.length;

	if (n == 0) return m;
	if (m == 0) return n;

	for (i = 0; i <= n; i++) d[i] = new Array();
	for (i = 0; i <= n; i++) d[i][0] = i;
	for (j = 0; j <= m; j++) d[0][j] = j;

	for (i = 1; i <= n; i++)
	{
		for (j = 1; j <= m; j++)
		{
			cost = (string1.charAt(i - 1) == string2.charAt(j-1) ? 0 : 1);
			d[i][j] = Math.min(d[i-1][j]+1, d[i][j-1]+1, d[i-1][j-1]+cost);
		}
	}
	
	return d[n][m];
}

var log = {};

log.trace = function (message) {
  if(window.console && window.console.firebug){
    console.log(message);
  }
  else {
    alert(message);
  }  
}

log.error = function (message) {
  if( (window.console && window.console.firebug) || console){
    console.error(message);
  }
  else {
    alert(message);
  }
}

function applyAndSortFunctions(){
	sorteado = rand(0,funcao.length-1);
	ai.setFunction(funcao[sorteado].f_display);
	//alert(sorteado);
}

function rand(l,u) // lower bound and upper bound
{
	return Math.floor((Math.random() * (u-l+1))+l);
}

// Mensagens de log
function message (m) {
	try {
		if (debug) console.log(m);
	}
	catch (error) {
		// Nada.
	}
}