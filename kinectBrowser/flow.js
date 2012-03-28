function createFlowController(div){
	var that = {};
	var items = div.children();
	items.each(function(){
		var $this = $(this);
		$this.data("width",$this.width());
		$this.data("height",$this.height());
	});
	var coveryState = 0.0;
	var selected = 1;

	var width = div.width();
	var height = div.height();
	$(window).resize(function() {
  		width = div.width();
		height = div.height();
		reposition();
	});
	function fittofull(item){
		var iw = item.data("width");
		var ih = item.data("height");
		var scale = Math.min(width/iw,height/ih);
		return scale;
	}
	function central(){
		var length = 0;
		var lengthBefore;
		items.each(function(index){
			$this = $(this);
			if(index<=selected){
				lengthBefore = length;
			}
			length += $this.width()+20;
		});
		var offs = items.eq(Math.round(selected)).width()/2;
		if(Math.round(selected)!=selected){
			var elso = items.eq(Math.floor(selected)).width();
			var masodik = items.eq(Math.ceil(selected)).width();
			var posBetween = selected-Math.floor(selected);
			posBetween = posBetween*coveryState+Math.round(posBetween)*(1-coveryState);
			var offs=posBetween*(elso+masodik/2)+(1-posBetween)*(elso/2);
		}
		var offx = width/2-lengthBefore-offs;
		items.each(function(index){
			$this = $(this);
			$this.css("left",offx+"px");
			offy = (height-$this.height())/2;
			$this.css("top",offy+"px");
			offx += $this.width()+20;
		});
	}
	function zoom(){
		var others;
		if(Math.round(selected)==selected){
			var sItem = items.eq(Math.round(selected));
			others = items.not(sItem);
			var extraScale = fittofull(sItem)*(1-coveryState)+0.4*coveryState;
			sItem.children().css("zoom",extraScale);
		}else{
			var posBetween = selected-Math.floor(selected);
			posBetween = posBetween*coveryState+Math.round(posBetween)*(1-coveryState);
			var firstItem = items.eq(Math.floor(selected));
			var secondItem = items.eq(Math.ceil(selected));
			others = items.not(firstItem).not(secondItem);
			var firstScale = fittofull(firstItem)*(1-coveryState)+0.4*coveryState;
			firsScale = firstScale*(1-posBetween)+0.2*posBetween;
			firstItem.children().css("zoom",firsScale);
			var secondScale = fittofull(secondItem)*(1-coveryState)+0.4*coveryState;
			secondScale = secondScale*posBetween+0.2*(1-posBetween);
			secondItem.children().css("zoom",secondScale);
			//log(posBetween+" "+firstScale+" "+secondScale);
		}
		others.children().css("zoom",0.2);
	}
	function reposition(){
		zoom();
		central();
		if(coveryState<0.1){
			$("#imageName").text(imageName(Math.round(selected)));
		}else{
			$("#imageName").text("");
		}
	}
	reposition();
	var resetTimer;
	function reset(){
		coveryState = (coveryState*3)/4;
		if(coveryState<0.01){
			coveryState = 0;
		}
		reposition();
		if(resetTimer){
			clearTimeout(resetTimer);
		}
		resetTimer = setTimeout(reset,100);
	};
	function delayReset(){
		if(resetTimer){
			clearTimeout(resetTimer);
		}
		resetTimer = setTimeout(reset,100);
	};
	var handsPos = {};
	that.eventHandler = function(handId,howCovery, delta){
		if(typeof howCovery === 'undefined'){
			delete handsPos[handId];
			return;
		}
		if(!(handId in handsPos)){
			handsPos[handId] = selected;
		}
		coveryState = (coveryState*7+howCovery)/8;
		var nselected = Math.max(0,Math.min(items.length-1,handsPos[handId]+delta/40));
		var oselected = selected;
		selected = (selected*7+nselected)/8;

		delayReset();
		//log("covery: "+coveryState+" "+delta);
		reposition();
	}
	return that;
}
var files = app.pictureList();
function imageName(index){
	path = files[index];
	var name = path.split("/");
	name = name[name.length-1];
	return name;
};
jQuery.each(files,function(index,file){
	kinect.log(file);
	$("#flow").append('<div class="item"><img  src="'+file+'"></div>');
});
function start(){
	var flow = createFlowController($("#flow"));
	coverFlowFunc = flow.eventHandler;
}
var loadedNum = 0;
$("#flow img").load(function(){
	loadedNum += 1;
	if(loadedNum>=files.length){
		start();
	}
});