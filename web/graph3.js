var datearray = [];
var colorrange = [];
var smhiDataR = [];
var strokecolor;
var format;



var ifFirst = true;

var x, 
  xAxis,
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

margin = {top: 40, right: 40, bottom: 100, left: 45};
width = document.body.clientWidth - margin.left - margin.right;
height = document.body.clientHeight - margin.top - margin.bottom;

colorrange = ["#32ACAF", "#E36790", "#F3C3C3C" ];
strokecolor = colorrange[0];

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

stack = d3.layout.stack()
  .offset("silhouette")
  .values(function(d) { return d.values; })
  .x(function(d) { return d.value; })
  .y(function(d) { return d.date; });

nest = d3.nest()
            .key(function(d){ 
              return d.key ; });

area = d3.svg.area()  
            .interpolate("cardinal")
            .x0(function(d){ return x(0.0) ; })
            .x1(function(d){  return x(d.value) ; })
            .y(function(d){ return y(d.date) ; });

svg = d3.select(".chart").append("svg")
          .attr("width", width + margin.left + margin.right) // här kan man ändra bredden
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

console.log("size: " + width.toString());

//den nya horisontella linjen
var horizontal = d3.select(".chart")
          .append("div")
          .attr("class", "remove")
          .style("position", "absolute")
          .style("z-index", "19")
          .style("width", width.toString() + "px")
          .style("height", "2px")
          .style("top", "50vh")
          .style("left", "15vw")
          .style("background", "#3c3c3c");

//puts both smhi and yr to an array, where they are divided in different parameters
function setParameters(smhiData, yrData, currentParameter){

  var i = 0;
  var j = 0;
  smhiDataR = [];


  //read in smhiData and store in smhiDataR
  while( smhiData.o[j] != null ){
    var singleObj = {};

    var time = smhiData.o[j].date.date.toISOString();

    singleObj['key'] = "smhi";
    singleObj['parameter'] =+ smhiData.o[j].currentParameter;
    singleObj['rainString'] = smhiData.o[j].rain;
    singleObj['cloudString'] = smhiData.o[j].cloud;
    singleObj['windString'] = smhiData.o[j].wind;
    singleObj['date'] = time;

    smhiDataR.push(singleObj);

    j++;

  }

  //read in yrData and store in smhiDataR
  while( yrData.o[i] != null){
    var singleObj = {};
    var time = yrData.o[i].date.date.toISOString();

    singleObj['key'] = "yr";
    singleObj['parameter'] =+ yrData.o[i].currentParameter;
    singleObj['rainString'] = yrData.o[i].rain;
    singleObj['cloudString'] = yrData.o[i].cloud;
    singleObj['windString'] = yrData.o[i].wind;
    singleObj['date'] = time;

    smhiDataR.push(singleObj);

    i++;

  }

  if(ifFirst){
    createGraph(smhiDataR, currentParameter);
    ifFirst = false;
  }
  else updateGraph(smhiDataR, currentParameter);

}


function updateGraph(smhiDataR, currentParameter){
  smhiDataR.forEach(function(d){
    d.date = format.parse(d.date);
    d.value =+ d.parameter;
  });
  
  layersSmhi1 = stack(nest.entries(smhiDataR));

  var maxOfCurrentX = d3.max(smhiDataR, function(d){return d.value; });

  if(currentParameter == "wind"){
    x.domain([0,100]);
  }else if(currentParameter == "rain"){
    x.domain([0,100]);
  }else if(currentParameter == "cloud"){
    x.domain([0,100]);
  }else{
    x.domain([-maxOfCurrentX, maxOfCurrentX]);
  }

  svg.select(".x.axis")
                    .transition().duration(3500).ease("sin-in-out")  // https://github.com/mbostock/d3/wiki/Transitions#wiki-d3_ease
                    .call(xAxis);  

  y.domain(d3.extent(smhiDataR, function(d){ return d.date; }));

  transition2(currentParameter);

}

function createGraph(smhiDataR, currentParameter){

    smhiDataR.forEach(function(d){

      d.date = format.parse(d.date);
      d.value =+ d.parameter;

    });

    layersSmhi0 = stack(nest.entries(smhiDataR));

    var maxOfCurrentX = d3.max(smhiDataR, function(d){ return d.value; }); 
    
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

    var today = new Date();
    
    svg.append("line")
      .attr("x1", 0)  //<<== change your code here
      .attr("y1", y(today))
      .attr("x2", width)  //<<== and here
      .attr("y2", y(today))
      .style("stroke-width", 2)
      .style("stroke", "red")
      .style("fill", "none");


    mouseHandler(currentParameter);


 
}


  function transition2(currentParameter){
        d3.selectAll("path")
        .data(function(){
          var d = layersSmhi1;
          layersSmhi1 = layersSmhi0;
          return layersSmhi0 = d;
        })
        .transition()
        .duration(3500)
        .attr("d", function(d){ return area(d.values); } );

        mouseHandler(currentParameter);

  }

  function mouseHandler(currentParameter){

  svg.selectAll(".layer")
    .attr("opacity", 0.5)
    .on("mouseover", function(d, i) {
      svg.selectAll(".layer").transition()
      .duration(250)
      .attr("stroke", strokecolor)
      .attr("stroke-width", "0.5px") 
      .attr("opacity", function(d, j) {
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

    
    updateHeader(invertedx, invertedy, currentParameter);   
    
  })
  
  //TODO:
  //ändra så att pinnen hamnar där en klickar
  d3.select(".chart")
    .on("mousemove", function(){ 
       mouse = d3.mouse(this);
       var scrollTop = (document.body.parentNode).scrollTop;
       mousey = (height+scrollTop)/2 + mouse[1];
       horizontal.style("top", mousey + "px" )})


    .on("mouseover", function(){  
       mouse = d3.mouse(this);

       //TODO: Take away this if it works
       //var scrollTop = (document.body.parentNode).scrollTop;
       //var scrollTop = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
       //mousey = (height+scrollTop)/2 + mouse[1];
       //horizontal.style("top", mousey + "px")});

       horizontal.style("top", mouse[1] + "px")});


  }

  function updateHeader(d, dy, currentParameter){
    
    // change to a function
    var y_time1 = dy.toString().substring(16,18); //hour
    var y1 = dy.toString().substring(0,16);
    var y2 = ":00:00";
    var y3 = dy.toString().substring(24,40);

    // get current date
    var today = new Date();
    today = today.getDate();


    //TODO: fix so the difference also works during two months
    // ta ut hela datumet och ej bara dagen
    var dateDiff = dy.toString().substring(8,10) - today;

    //find the right day and time to compare with
    var smhiTime = findCorrectDate(dateDiff, "smhi");
    var yrTime = findCorrectDate(dateDiff, "yr");

    //finds the nearest parameter in date 
    function findCorrectDate(difference, key){

      //find right y-sampel from smhi
      if(key == "smhi"){
        if(difference == 0 || difference == 1) return (y1 + y_time1 + y2 + y3);

        else if(difference == 2){
          // avaible y-samples i commented over all if-statements
          // 00->14, 17, 20 , 23

          if(y_time1 <= 14 && y_time1 >= 00) return (y1 + y_time1 + y2 + y3);
          else if(y_time1 <= 18 && y_time1 >= 15) return (y1 + "17" + y2 + y3);
          else if(y_time1 <=21 && y_time1 >= 16) return (y1 + "20" + y2 + y3);
          else return (y1 + "23" + y2 + y3);
            
        }

        else if(difference == 3 || difference == 4 || difference == 5){
          // 02, 08, 14, 20
          if(y_time1 <= 05 && y_time1 >= 00) return (y1 + "02" + y2 + y3);
          else if(y_time1 <= 11 && y_time1 >= 06) return (y1 + "08" + y2 + y3);
          else if(y_time1 <= 16 && y_time1 >= 12) return (y1 + "14" + y2 + y3);
          else return (y1 + "20" + y2 + y3);

        }

        else if(difference == 6){
          // 02, 08, 14
          if(y_time1 <= 05 && y_time1 >= 00) return (y1 + "00" + y2 + y3);
          else if(y_time1 <= 11 && y_time1 >= 06) return (y1 + "08" + y2 + y3);
          else return (y1 + "14" + y2 + y3);

        }

        else if(difference == 7 || difference == 8 || difference == 9 ){
          // 02, 14
          if(y_time1 <= 09 && y_time1 >= 00) return (y1 + "00" + y2 + y3);
          else return (y1 + "14" + y2 + y3);

        }
        else console.log("something is wrong dude");
      }

      //find right y-sampel from yr
      else {
        if(difference == 0 || difference == 1 || difference == 2) return (y1 + y_time1 + y2 + y3);

        else if(difference == 3 ||difference == 4 || difference == 5 || difference == 6){

          //at 02, 08, 14 20
          if(y_time1 <= 05 && y_time1 >= 00) return (y1 + "02" + y2 + y3);
          else if(y_time1 <= 11 && y_time1 >= 06) return (y1 + "08" + y2 + y3);
          else if(y_time1 <= 16 && y_time1 >= 12) return (y1 + "14" + y2 + y3);
          else return (y1 + "20" + y2 + y3);

        }

        else if(difference == 7 || difference == 8 || difference == 9){
          // 02 och 08 14
          if(y_time1 <= 05 && y_time1 >= 00) return (y1 + "02" + y2 + y3); 
          if(y_time1 <= 11 && y_time1 >= 06) return (y1 + "08" + y2 + y3); 
          else return (y1 + "14" + y2 + y3); 
   
        }
        else console.log("something is wrong dude");

      }
 
    }

     
    // update smhiHeader
    var smhiElement = document.getElementById("headerTextSmhi"); 
    //update yrHeader
    var yrElement = document.getElementById("headerTextYr");

    // finds the corresponding x-value in smhiDataR to the graphs y-axis
    function filterByTemp(obj) {
    	     
      if(obj.key == "smhi" && obj.date == smhiTime) {
          //update the header
          if(smhiElement == null) console.log("something went wrong");

          else {

          	if(currentParameter == "temp")
          	{
          		if(obj.parameter >= 10) obj.parameter = obj.parameter.toString().substring(0,4) + " °C";//RIQQUES
            	else obj.parameter = obj.parameter.toString().substring(0,3) + " °C";
            }
            else if(currentParameter == "rain"){
            	obj.parameter = obj.rainString ;
            }
            else if(currentParameter == "wind"){
            	obj.parameter = obj.windString;
            }
            else if(currentParameter == "cloud"){
            	obj.parameter = obj.cloudString;
            }
            
            smhiElement.innerHTML = obj.parameter;//.toString();
            //obj.temp = (obj.temp.toString()).substring(0, 3) + " °C"; 

            if(y_time1 > 21 || y_time1 < 05) document.getElementById('smhiID').src = headerImages[1]; //set to night image

            else{
            	if(obj.rainString == "Inget regn"){
		        if(obj.cloudString == "Sol"){
		           document.getElementById('smhiID').src = headerImages[2];//sol + fåglar
		        }
		        else if(obj.cloudString == "Lite moln"){
		          document.getElementById('smhiID').src = headerImages[6]; //sol + lite moln + fåglar
		        }
		        else if(obj.cloudString == "Växlande molnighet"){
		          document.getElementById('smhiID').src = headerImages[7];
		        }
		        else if(obj.cloudString == "Mulet"){
		          document.getElementById('smhiID').src = headerImages[9]; //moln
		        }
		      }

		     if(obj.rainString.substring(0,4) == "Duggregn"){
        		document.getElementById('smhiID').src = headerImages[3]; //lite regn
		      }
		      if(obj.rainString.substring(0,4) == "Regn"){
		        document.getElementById('smhiID').src = headerImages[0]; //mycket regn
		      }
		      if(obj.rainString.substring(0,4) == "Snö" && obj.cloudString == "Mulet"){
		        document.getElementById('smhiID').src = headerImages[5];//snö
		      } 
		      if(obj.rainString.substring(0,4) == "Snö" && obj.cloudString == "Växlande molnighet"){
		        document.getElementById('smhiID').src = headerImages[4];//snö och sol 
		      } 
		      if(obj.rainString == "Hagel" && obj.cloudString == "Mulet"){
		        document.getElementById('smhiID').src = headerImages[5];//snö   
		      }
		      if(obj.rainString == "Hagel" && obj.cloudString == "Växlande molnighet"){
		        document.getElementById('smhiID').src = headerImages[4];//snö och sol 
		      }
		    } 
          
          }

          return true; 
      } 

      else if(obj.key == "yr" && obj.date == yrTime) {
        //update header
        if(yrElement == null) console.log("something went wrong with yr");
        else {
        	if(currentParameter == "temp")
          	{
          		if(obj.parameter >= 10) obj.parameter = obj.parameter.toString().substring(0,4) + " °C";//.toString()).substring(0,4)
            	else obj.parameter = obj.parameter.toString().substring(0,3) + " °C"; //.toString()).substring(0, 3) 
            }
            else if(currentParameter == "rain"){
            	obj.parameter = obj.rainString;
            }
            else if(currentParameter == "wind"){
            	obj.parameter = obj.windString;
            }
            else if(currentParameter == "cloud"){
            	obj.parameter = obj.cloudString;
            }
            
            yrElement.innerHTML = obj.parameter;//.toString();

            if(y_time1 > 21 || y_time1 < 05) document.getElementById('yrID').src = headerImages[1]; //set to night image

            else{
            	if(obj.rainString == "Inget regn"){
			        if(obj.cloudString == "Sol"){
			           document.getElementById('yrID').src = headerImages[2];//sol + fåglar
			        }
			        else if(obj.cloudString == "Lite moln"){
			          document.getElementById('yrID').src = headerImages[6]; //sol + lite moln + fåglar
			        }
			        else if(obj.cloudString == "Växlande molnighet"){
			          document.getElementById('yrID').src = headerImages[7];
			        }
			        else if(obj.cloudString == "Mulet"){
			          document.getElementById('yrID').src = headerImages[9]; //moln
			        }
		      }

		     if(obj.rainString.substring(0,4) == "Duggregn"){
        		document.getElementById('yrID').src = headerImages[3]; //lite regn
		      }
		      if(obj.rainString.substring(0,4) == "Regn"){
		        document.getElementById('yrID').src = headerImages[0]; //mycket regn
		      }
		      if(obj.rainString.substring(0,4) == "Snö" && obj.cloudString == "Mulet"){
		        document.getElementById('yrID').src = headerImages[5];//snö
		      } 
		      if(obj.rainString.substring(0,4) == "Snö" && obj.cloudString == "Växlande molnighet"){
		        document.getElementById('yrID').src = headerImages[4];//snö och sol 
		      } 
		      if(obj.rainString == "Hagel" && obj.cloudString == "Mulet"){
		        document.getElementById('yrID').src = headerImages[5];//snö   
		      }
		      if(obj.rainString == "Hagel" && obj.cloudString == "Växlande molnighet"){
		        document.getElementById('yrID').src = headerImages[4];//snö och sol 
		      }
		    } 
         
      }

        return true;

      }
      else return false;

  }

    //TODO: felmeddelande om användaren klickar utanför?
    var arrbyTemp = smhiDataR.filter(filterByTemp);    




}





