var findYou = false;
var profile_visible = false;

	$(document).ready(function() {

		calculateCentre('div#loader','div#mamufas',218);
		$('#loader').fadeIn('slow');
		
		//Sizing elements at the start
		onResize();
		//Getting game users rank
		getGameRank();
		//Binding when window is resizing...
		window.onresize = function() { onResize();}
		
		$('div.header ul li').click(function(ev){
			if (!$(this).hasClass('selected')) {
				removePreviousSelected();
				$(this).addClass('selected');
			}
		});

  });


	function removeAllActive() {
		$('div.profile ul.options li').each(function(index){	
			if ($(this).hasClass('active')) {
				$(this).removeClass('active');				
			}
		});
	}


	function getRankingEnd(number) {
		switch (number) {
			case 1: return 'st'; break;
			case 2: return 'nd'; break;
			case 3: return 'rd'; break;
			default: return 'th';
		}
	}
	
	
	function showProfile() {
		$('li.you div.bottom a').fadeOut(200,function(ev){
			$('a.gotomap').fadeIn(300);
		});
		
		$("#slider").animate(
			{ left: 300 }, 
			{ duration: 300,
		    specialEasing: 'easeOutElastic'
		}).animate(
					{ left: 220 }, 
					{ duration: 200,
				    specialEasing: 'easeOutBounce',
						complete: function() {
							$('div.left_column ul li').css('background','url(../images/li_bkg_profile.png) repeat-y 0 0');
							profile_visible = true;
						}
					});
	}
	
	
	
	function hideProfile() {
		$('li.you div.bottom a.gotomap').fadeOut(200,function(ev){
			$('a.ranking').fadeIn(200);
			$('a.profile').fadeIn(200);
		});
		
		$('div.left_column ul li').css('background','#232323');

		$("#slider").animate(
				{ left: 300 }, 
				{ duration: 300,
			    specialEasing: 'easeOutElastic'
			}).animate(
						{ left: -window.innerWidth+220 }, 
						{ duration: 200,
					    specialEasing: 'easeOutBounce',
							complete: function() {
								profile_visible = false;
							}
				 });
	}
	
	

	function onResize() {
		$('#map_canvas').css('height',window.innerHeight+'px');
		$('#map_canvas').css('width',window.innerWidth-220+'px');
		$('ul#main_list').css('height',window.innerHeight-94+'px');
		$('#mamufas').css('width',window.innerWidth-220+'px');
		$('div.profile').css('width',window.innerWidth-220+'px');
		$('div.profile').css('height','100%');
		if (profile_visible) {
			$('div.profile').css('left','220px');
		} else {
			$('div.profile').css('left',-window.innerWidth+220+'px');
		}
		$('div.feed_container').css('width',window.innerWidth-270);
		$('div.feed_container').css('height',window.innerHeight-110);
		
		calculateCentre('div#loader','div#mamufas',218);
	}

	function checkLengthUsername(username) {
		if (username.length>13) {
			return username.substring(0,10) + '...';
		} else {
			return username;
		}
	}

	function getGameRank() {
		
		$.ajax({
		   type: "GET",
		   url: "users/rank",
		   success: function(result) {
					$('ul#main_list').html('');
					findYou = false;
					for (var i=0; i<result.length; i++) {
						if (!result[i].current_user) {
							var color = !findYou ? 'red':'green';
							var firstItem = i==0 ? 'class="first"': ''; 
							var li_html = '<li '+firstItem+'><div class="image"><img src="'+result[i].avatar+'" alt="'+result[i].username+'"/></div><div class="data"><p >'+checkLengthUsername(result[i].username)+'<sup>('+result[i].rank+getRankingEnd(result[i].rank)+')</sup></p><p class="number">'+fillWithZeros(result[i].meters_explored,false)+'m<small class="'+ color+'">('+result[i].meters_different+'m)</small></p></div></li>';
							$('ul#main_list').append(li_html);
						} else {
							findYou = true;
							var li_html = '<li class="you"><div class="top"><div class="image"><img src="'+result[i].avatar+'" alt="'+result[i].username+'"/></div><div class="data"><p >'+checkLengthUsername(result[i].username)+'<sup>('+result[i].rank+getRankingEnd(result[i].rank)+')</sup></p><p class="number">'+fillWithZeros(result[i].meters_explored,true) +'<label>METERS <br />DONE</label></p></div></div><div class="bottom"><a class="ranking" href="#"></a><a class="profile" href="javascript:showProfile();"></a><a class="gotomap" href="javascript:hideProfile();"></a></div>';
							$('ul#main_list').append(li_html);
						}
					}
		   }
		 });
	}
	
	
	function fillWithZeros(number,kind) {
		var newNumber = number.toString();
		var needed_zeros = 8 - newNumber.length; 
		for (var i=0; i<needed_zeros;i++) {
			newNumber = '0' + newNumber;
		}
		if (!kind) {
			return newNumber;
		} else {
			var ul_html = '';
			for (var j=0; j<8; j++) {
				ul_html = ul_html + '<li>'+ newNumber.substring(j,j+1) +'</li>' ;
			}
			return '<ul>' + ul_html + '</ul>';
		}
	}
	
	
	function calculateCentre(element,parent,offset_left) {
		var width_element = $(element).width()/2; 
		var height_element = $(element).height()/2;
		
		var left_position = ($(parent).width()/2) - width_element;
		var top_position = ($(parent).height()/2) - height_element;
		
		$(element).css('left',left_position + offset_left +'px');
		$(element).css('top',top_position+'px');
	}
	
	
	
	function hideLoading(){	
		$('#loader').fadeOut('slow',function(ev){
			$('#mamufas').fadeOut('fast');
		});
	}


	function showLoading(){	
		$('#loader').fadeIn('slow',function(ev){
			$('#mamufas').fadeIn('fast');
		});
	}


	function showResponse(str){
		$('#response').text(str);
		$('#response').stop(true).fadeTo('fast',1,function(ev){
			$('#response').delay(1000).fadeTo('fast',0);
		});
	}


	function removePreviousSelected() {
		$('div.header ul li').each( function(index){
			$(this).removeClass('selected');
		});
	}

	
	
	
