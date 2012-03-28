var buttons = [];
var settings = {};
jQuery.getJSON("file://"+app.directory()+"/settings.txt",function(data){
	settings = data;
	kinect.log("settings loaded");
});

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

function createHand(handId){
	var that = {};
	var item = $("<div class='hand'><div class='agitatedhand'></div></div>");
	var pos = [0,0];
	$("body").append(item);
	var ofx = item.width()/2;
	var ofy = item.height()/2;
	var coverActive = false;
	var coverD;
	var agitationLevel = 0;
	var whichHand;
	function draw(){
		item.css("left",(pos[0]-ofx)+"px");
		item.css("top",(pos[1]-ofy)+"px");
		item.children().css("opacity",Math.max(0.0,Math.min(agitationLevel/80,1)));
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
	function coverFlowHandler(handPos,userPos){
		var zDif = (userPos[2]-handPos.z);
		if(whichHand=="left"){
			var xDif = (userPos[0]-250-handPos.x);
		}else{
			var xDif = (userPos[0]+250-handPos.x);
		}
		
		var distance = Math.sqrt(zDif*zDif+xDif*xDif);
		var direction = Math.atan2(xDif,zDif)* (180/Math.PI);
		if(distance>200){
			if(!coverActive){
				coverActive = true;
				coverD= direction;
			}
			coverFlowFunc(handId,Math.min((distance-200)/20,1),Math.round(direction-coverD));
		}else{
			coverActive = false;
			coverFlowFunc(handId);
		}
	};
	that.move = function(handPos,userPos){
		if(!whichHand){
			if(userPos[0]>handPos.x){
				whichHand = "left";
			}else{
				whichHand = "right";
			}
		}
		//log(pos.x-userPos[0]);
        var npos=[];
		npos[0] = $(window).width()*((handPos.x-userPos[0])/settings.sensitivity+settings.xOffset);
        pos[0] = (pos[0]*8+npos[0])/9;
		npos[1] = $(window).height()*((handPos.y-userPos[1])/(-1*settings.sensitivity)+settings.yOffset);
        pos[1] = (pos[1]*8+npos[1])/9;
		draw();
		coverFlowHandler(handPos,userPos);
		buttonPushDetection();
		scrollDetection();
	}
	that.del = function(){
		if(coverActive){
		//	coverFlowFunc(handId);
		}
		item.remove();
	};
	return that;
}

var coverFlowFunc = function(){}
var hands = {};

var kinectCallback={
	gestureRecognized:function(e){
		if(e.gesture=="RaiseHand"){
			kinect.trackHand(e.pos);
		}
	},
	handMove:function(e){
		var user = kinect.whoIsThere(e.pos);
		if(user != -1){
			var userPos = kinect.whereUser(user);
			var id = e.handId;
			if(!(id in hands)){
				hands[id] = createHand(id);
			}
			hands[id].move(e.pos,userPos);
		}
	},
	handLost:function(id){
		if(id in hands){
			hands[id].del();
			delete hands[id];
		}
	}
};

function log(a){
	$("#msg").text(a);
};

$(document).keydown(function(){
	log("k");
});
