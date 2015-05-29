var datearray = [];
var colorrange = [];
var smhiDataR = [];
var strokecolor;
var format;

var ifFirst = true;

var tooltip, 
  x, xAxis,
  y, yAxis,
  z;

var stack, nest, area, svg;

var margin, width, height;
  
var layersSmhi0, layersSmhi1, layersYr0, layersYr1;

var headerImages = ["https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkSVNjM1VzdGJxeUk", 
                           "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_d185SXd5UzNkcTA",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkQTNqLXQ2eVl1cVE",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkeUk2YmJCM2FnRlk",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkQUR3UXh3UTJJME0",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkS3BGbjFFRXZHaEE",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkeGd0b2Jpc01UU0E",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkOHhwV3lxM2c0a2s",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkVTlXenJvVUx0ZzQ",
                           "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkdVpoMlV5VDlPRHM",
                           "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_TUFQSlNMdHE3SzA"];


format = d3.time.format.utc("%Y-%m-%dT%H:%M:%S.%LZ");
  

//TODO:
//Make these responsive
//är dem inte redan det?
margin = {top: 40, right: 40, bottom: 100, left: 45};
width = document.body.clientWidth - margin.left - margin.right;
height = document.body.clientHeight - margin.top - margin.bottom;


//TODO: 
//When yrData is added, add one color.
colorrange = ["#E36790", "#32ACAF", "#F3C3C3C" ];
strokecolor = colorrange[0];

//TODO: 
//Uncomment this part, not working right now..
tooltip = d3.select("body")
  .append("div")
  .attr("class", "remove")
  .attr("id", "removeMe")
  .style("position", "absolute")
  .style("z-index", "20")
  .style("visibility", "hidden")
  .style("top", "30px")
  .style("left", "55px");

x = d3.scale.linear()
        .range([0,width]);

y = d3.time.scale()
        .range([0, height]);
        

z = d3.scale.ordinal()
        .range(colorrange);

xAxis = d3.svg.axis()
            .scale(x);
            //.orient("bottom");

yAxis = d3.svg.axis()
            .scale(y)
            //.orient("right")
            .ticks(d3.time.days)
            .tickFormat(d3.time.format('%a'));
           // console.log(d3.time.days);
           //d.date = format.parse(d.date)

stack = d3.layout.stack()
  .offset("silhouette")
  .values(function(d) { return d.values; })
  .x(function(d) { return d.value; })
  .y(function(d) { return d.date; });

nest = d3.nest()
            .key(function(d){ 
               // console.log(d.key); 
              return d.key ; });
//TODO:
//Jag tror att x(d.x0) och x(d.x0 + d.x) är de som dummar sig,
//tror det räcker med att x0 = x0(function(d){return 0;})
area = d3.svg.area()  
            .interpolate("cardinal")
            .x0(function(d){ return x(0.0) ; })
            .x1(function(d){  return x(d.value) ; })
            .y(function(d){ return y(d.date) ; });
//TODO:
//Jag är inte 100% på hur  den funkar, men slår vi våra kloka 
//huvuden ihop kan vi säkert lösa det.. 
svg = d3.select(".chart").append("svg")
          .attr("width", width + margin.left + margin.right) // här kan man ändra bredden
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


//den nya horisontella linjen
var horizontal = d3.select(".chart")
          .append("div")
          .attr("class", "remove")
          .style("position", "absolute")
          .style("z-index", "19")
          .style("width", "110px")
          .style("height", "2px")
          .style("top", "50vh")
          .style("bottom", "30px")
          .style("left", "50vw")
          .style("background", "#3c3c3c");

function setParameters(smhiData, yrData, currentParameter){
  //TODO: 
  //Denna delen känns lite konstig, översätter från en list med obj
  //till en lista med exakt samma objekt
  var i = 0;
  var j = 0;
  smhiDataR = [];

  //read in yrData and store in smhiDataR
  while(yrData.o[i] != null){
    var singleObj = {};

    var time = yrData.o[i].date.date.toISOString();
    
    singleObj['key'] = "yr";
    singleObj['temp'] =+ yrData.o[i].currentParameter;
    singleObj['date'] = time;
    
    smhiDataR.push(singleObj);
    i++;

  }

  //read in smhiData and store in smhiDataR
  while( j < i ){
    var singleObj = {};

    var time = smhiData.o[j].date.date.toISOString();
    
    singleObj['key'] = "smhi";
    singleObj['temp'] =+ smhiData.o[j].currentParameter;
    singleObj['date'] = time;

    smhiDataR.push(singleObj);
    j++;

  }


  if(ifFirst){
    createGraph(smhiDataR);
    ifFirst = false;
  }else{
    updateGraph(smhiDataR);
  }


}


function updateGraph(smhiDataR){
  smhiDataR.forEach(function(d){
    d.date = format.parse(d.date);
    d.value =+ d.temp;
    d.rain = d.rain;
    console.log(d.rain);
  });
layersSmhi1 = stack(nest.entries(smhiDataR));

  var maxOfCurrentX = d3.max(smhiDataR, function(d){return d.value; }); 

  //maxOfCurrentX = 150;
  
  x.domain([-maxOfCurrentX, maxOfCurrentX]);
  y.domain(d3.extent(smhiDataR, function(d){ return d.date; }));

transition2();

}

function createGraph(smhiDataR){

    smhiDataR.forEach(function(d){
      d.date = format.parse(d.date);
      d.value =+ d.temp;

    });

    //TODO:
    //Denna ska fungera, men den gör inte riktigt det än.. Av någon anledning blir antingen d.y0 eller d.y noll
    //Just nu är det hårdkodat nedanför..
    //x.domain([0, d3.extent(smhiDataR, function(d) { return d.y0 + d.y ; })]);

    layersSmhi0 = stack(nest.entries(smhiDataR));
    //TODO: 
    //this can be used, when it contains YR-data also
    /*var maxOfCurrentX = d3.max(smhiDataR, function(d){
      return d3.max(d);
    });*/
    var maxOfCurrentX = d3.max(smhiDataR, function(d){return d.value; }); 
    
    x.domain([-maxOfCurrentX, maxOfCurrentX]);
    y.domain(d3.extent(smhiDataR, function(d){ return d.date; }));

    //svg.transition();

    svg.selectAll(".layer")
          .data(layersSmhi0)
          .enter().append("path")
          .attr("class","layer")
          .attr("d", function(d){ return area(d.values); })
          .style("fill", function(d, i){ return z(i); });
  
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + 0 + ")")
      .call(xAxis.orient("top"));

    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + 0 + ", 0)")
      .call(yAxis.orient("left"));

      mouseHandler();
    //TODO: 
    //Här kan man lägga till så att tooltippen uppdateras
    //och startas, dock måste man lägga till var tooltip först
    //svg.selectAll(".layer")
    //.attr("opacity", 1) osv..  
}


  function transition2(){
        d3.selectAll("path")
        .data(function(){
          var d = layersSmhi1;
          layersSmhi1 = layersSmhi0;
          return layersSmhi0 = d;
        })
        .transition()
        .duration(3500)
        .attr("d", function(d){ return area(d.values); } );

        mouseHandler();

  }

  function mouseHandler(){
    //TODO: 
  //Här kan man lägga till så att tooltippen uppdateras
  //och startas, dock måste man lägga till var tooltip först
  //svg.selectAll(".layer")
  //.attr("opacity", 1) osv..

  svg.selectAll(".layer")
    .attr("opacity", 1)
    .on("mouseover", function(d, i) {
      svg.selectAll(".layer").transition()
      .duration(250)
      .attr("opacity", function(d, j) {
        console.log("check me out");
        return j != i ? 0.6 : 1;
    })})

.on("click", function(d, i) {
    mouse = d3.mouse(this); //Returns the x and y coordinates of the current d3.event,
                             //The coordinates are returned as a two-element array [x, y].

    mousex = mouse[0];
    mousey = mouse[1];



    //invertedx = invertedx.getTime();
    //scale.invert(y) Returns the date in the input domain x for the corresponding value in the output range y
    //Vi vill ha input domain y i corresponding output range x
    

    //These contains our values, depending on where the mouse is..
    var invertedx = x.invert(mousex);
    var invertedy = y.invert(mousey);

    console.log("test" + d.date);
    updateHeader(invertedx, invertedy, d.key);    
    /*
    var selected = (d.values);
    selected = d.values;
    for (var k = 0; k < selected.length; k++) {
      datearray[k] = selected[k].date;
      datearray[k] = datearray[k].getMonth() + datearray[k].getDate();
    }

    mousedate = datearray.indexOf(invertedx);
    pro = d.values[mousedate].value;
    
    d3.select(this)
    .classed("hover", true)
    .attr("stroke", strokecolor)
    .attr("stroke-width", "0.5px"), 
    tooltip.html( "<p>" + d.key + "<br>" + pro + "</p>" ).style("visibility", "visible");
    */
  })

  //ändra så att pinnen går upp och ner istället för höger och vänster
  d3.select(".chart")
    .on("mousemove", function(){ 
       mouse = d3.mouse(this);
       mousey = mouse[1] + document.body.clientHeight / 2;
       horizontal.style("top", mousey + "px" )})

      //

    .on("mouseover", function(){  
       mouse = d3.mouse(this);
       mousey = mouse[1] + document.body.clientHeight / 2;
       horizontal.style("top", mousey + "px")});
  }

  function updateHeader(x, y, k){
    // update smhiHeader
    var smhiElement = document.getElementById("headerTextSmhi");
    
    if(smhiElement == null) console.log("something went wrong");
    else {

    //update value
      //d = d.toString();
      if(k == "smhi"){
        if(x >= 10) x = (x.toString()).substring(0,4) + " °C";
        else x = (x.toString()).substring(0, 3) + " °C"; 
        smhiElement.innerHTML = x.toString();
      
	      //update header image
	      console.log(y.toString().substring(16,18));
	      console.log(y);

	      var time = y.toString().substring(16,18);
	      //var theTime = int.parse(time);
		
	      if(time > 21 || time < 05){
	      	//set to night image
	      	document.getElementById("#smhiID").src = headerImages[1];
	      }
	      else{
	      	//console.log(r.toString());
	      	console.log(r);
	      	document.getElementById("smhiID").src = headerImages[0];
	    	}
	        
      	
			
	      }

      }
      

    

    //update yrHeader
    var yrElement = document.getElementById("headerTextYr");
    
    if(yrElement == null) console.log("something went wrong");
    else {

      //d = d.toString();
      if(k == "yr"){
        if(x >= 10) x = (x.toString()).substring(0,4) + " °C";
        else x = (x.toString()).substring(0, 3) + " °C"; 
        
        yrElement.innerHTML = x.toString();
      }
    }
      

	}
