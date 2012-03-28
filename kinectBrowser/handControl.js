var buttons = [];

function createButton(elem,callback){
	var that = {};
	var item = $(elem);
	that.hit = function buttonHit(pos){
		var offset = item.offset();
		var width = item.width();
		var height = item.height();
		//app.log(JSON.stringify(offset));
		return (pos[0]>offset.left)&&(pos[0]<offset.left+width)&&(pos[1]>offset.top)&&(pos[1]<offset.top+height);
	};
	that.click = function buttonClick(){
		item.click();
		if(callback){
			callback();
		}
	};
	buttons.push(that);
}

function createHand(ox,oy,oz){
	var that = {};
	var item = $("<div class='hand'></div>");
	var pos = [0,0];
	$("body").append(item);
	var ofx = item.width()/2;
	var ofy = item.height()/2;
	var agitationLevel = 0;
	function draw(){
		item.css("left",(pos[0]-ofx)+"px");
		item.css("top",(pos[1]-ofy)+"px");
		item.css("background-color","rgba(0,0,255,"+(agitationLevel/100)+")");
	};
	function buttonPushDetection(){
		var agitate = false;
		$.each(buttons,function(index,button){
			if(button.hit(pos)){
				agitate = true;
				if(agitationLevel>80){
					button.click();
					agitationLevel = 0;
				}
			}
		});
		if(agitate){
			agitationLevel+=1;
		}else{
			if(agitationLevel>3){
				agitationLevel=agitationLevel*0.5;
			}else{
				agitationLevel=0;
			}
		}

	};
	var content = $("#content");
	function scrollDetection(){
		if(pos[0]<content.width()){
			if(pos[1]<100){
				content.scrollTop(content.scrollTop()-10);
			}
			if(pos[1]>content.height()-100){
				content.scrollTop(content.scrollTop()+10);
			}
		}
	};
	that.move = function(x,y,z){
		var ratio = 1.5;
        var npos=[];
		npos[0] = $(window).width()*((x-ox)/700+0.5);
        pos[0] = (pos[0]*8+npos[0])/9;
		npos[1] = $(window).height()*((y-oy)/-400+0.5);
        pos[1] = (pos[1]*8+npos[1])/9;
		draw();
		buttonPushDetection();
		scrollDetection();
	}
	that.delete = function(){
		item.remove();
	};
	return that;
}

var hands = {};
function handMove(id,x,y,z){
	if(id in hands){
		hands[id].move(x,y,z);
	}else{
		hands[id] = createHand(x,y,z);
	}
};
function handLost(id){
	if(id in hands){
		hands[id].delete();
		delete hands[id];
	}
}
