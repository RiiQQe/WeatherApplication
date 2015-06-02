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
//nej, grafen ändrar inte size när fönstret gör det.
//inte hög prio dock..
margin = {top: 40, right: 40, bottom: 100, left: 45};
width = document.body.clientWidth - margin.left - margin.right;
height = document.body.clientHeight - margin.top - margin.bottom;

colorrange = ["#32ACAF", "#E36790", "#F3C3C3C" ];
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
          .style("width", "400px")
          .style("height", "2px")
          .style("top", "50vh")
          .style("left", "15vw")
          .style("background", "#3c3c3c");

function setParameters(smhiData, yrData, currentParameter){
  console.log("inne i setParameters");
  //TODO: 
  //Denna delen känns lite konstig, översätter från en list med obj
  //till en lista med exakt samma objekt
  var i = 0;
  var j = 0;
  smhiDataR = [];
  //console.log("curr: " + currentParameter)

    //read in smhiData and store in smhiDataR
  while( smhiData.o[j] != null ){
    var singleObj = {};

    var time = smhiData.o[j].date.date.toISOString();
    
    singleObj['key'] = "smhi";
    singleObj['parameter'] =+ smhiData.o[j].currentParameter;
    singleObj['date'] = time;

    console.log("smhidate: " + time.toString());

    smhiDataR.push(singleObj);
   //con console.log(singleObj);

    j++;

  }

  //read in yrData and store in smhiDataR
  while( i < j){
    var singleObj = {};

    var time = yrData.o[i].date.date.toISOString();
    
    singleObj['key'] = "yr";
    singleObj['parameter'] =+ yrData.o[i].currentParameter;
    singleObj['date'] = time;


    console.log("Yrdate: " + time.toString());
    
    smhiDataR.push(singleObj);
    // console.log(singleObj);

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

  //maxOfCurrentX = 150;
  
  x.domain([-maxOfCurrentX, maxOfCurrentX]);
  y.domain(d3.extent(smhiDataR, function(d){ return d.date; }));

  transition2(currentParameter);

}

function createGraph(smhiDataR, currentParameter){

    smhiDataR.forEach(function(d){
      d.date = format.parse(d.date);
      d.value =+ d.parameter;

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

      mouseHandler(currentParameter);
    //TODO: 
    //Här kan man lägga till så att tooltippen uppdateras
    //och startas, dock måste man lägga till var tooltip först
    //svg.selectAll(".layer")
    //.attr("opacity", 1) osv..  
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
    
   // console.log("currentParameter: " + currentParameter);
    // console.log("d: " + d);
    
    // change to a function
    var y_time1 = dy.toString().substring(16,18); //hour
    var y1 = dy.toString().substring(0,16);
    var y2 = ":00:00";
    var y3 = dy.toString().substring(24,40);
    var y_time = y1+y_time1+y2+y3;

    // console.log("y_time: " + y_time);
   // console.log("dy: " + dy);

  // y_time = Thu Jun 04 2015 22:00:00 GMT+0200 (CEST)    

    // 2015-05-30T04:00:00.000Z

    var date = dy.toString().substring(8, 10); //dag
    var year = dy.toString().substring(11, 15); //år
    var month = "06";

    var y_value = year + "-" + month + "-" + date + "T" + y_time1 + y2 + ".000Z";
    var hej = y_value.toString;

  //  console.log("y_value: " + y_value);

    // update smhiHeader
    var smhiElement = document.getElementById("headerTextSmhi"); 
    //update yrHeader
    var yrElement = document.getElementById("headerTextYr");

    // finds the corresponding x-value in smhiDataR to the graphs y-axis
    function filterByTemp(obj) {
    //  console.log("obj.key = " + obj.key);

      // console.log("obj.date: " + obj.date);
      if(obj.key == "smhi" && currentParameter == "temp" && d.date == hej) {
      //    console.log("i if smhi: " + obj.key);
          //update the header
          if(smhiElement == null) console.log("something went wrong with smhi");
          else {
            if(obj.temp >= 10) obj.temp = (obj.temp.toString()).substring(0,4) + " °C";
            else{
              obj.temp = (obj.temp.toString()).substring(0, 3) + " °C"; 
              smhiElement.innerHTML = obj.temp.toString();

              //THIS IS NEW. UNCOMMENT IF IT DOESN'T WORK
        //      if(y_time1 > 21 || y_time1 < 05){
           //   //set to night image
           //   document.getElementById("#smhiID").src = headerImages[1];
           //  }
           //  else{
           //   document.getElementById("smhiID").src = headerImages[0];
            // }
          //END OF NEW
            } 
          
          }

          return true; 
      } 
      else if(obj.key == "yr" && obj.date == y_value) {
      //  console.log("i if yr: " + obj.key);
        //update header
        if(yrElement == null) console.log("something went wrong with yr");
        else {

            if(obj.temp >= 10) obj.temp = (obj.temp.toString()).substring(0,4) + " °C";
            else obj.temp = (obj.temp.toString()).substring(0, 3) + " °C"; 
            
            yrElement.innerHTML = obj.temp.toString();
          
        }

        return true;

      }
      else return false;

    }

    //TODO: felmeddelande om användaren klickar utanför?
    var arrbyTemp = smhiDataR.filter(filterByTemp);    

  }