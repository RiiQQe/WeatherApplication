var datearray = [];
var colorrange = [];
var smhiDataR = [];
var strokecolor;
var format;

var tooltip, 
  x, xAxis,
  y, yAxis,
  z;

var stack, nest, area, svg;

var margin, width, height;



function init(color){

  format = d3.time.format.utc("%Y-%m-%dT%H:%M:%S.%LZ");//"%Y-%m-%d
  //dateformat = d3.time.format("%Y-%m-%d");
  //TODO:
  //Make these responsive
  //är dem inte redan det?
  margin = {top: 20, right: 40, bottom: 30, left: 45};
  width = document.body.clientWidth - margin.left - margin.right;
  height = document.body.clientHeight - margin.top - margin.bottom;


  //TODO: 
  //When yrData is added, add one color.
  colorrange = ["#32acaf", "#353b4f"]; //smhi-color
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
              .key(function(d){ return d.key ; });
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

}

function setParameters(smhiData){
  //TODO: 
  //Denna delen känns lite konstig, översätter från en list med obj
  //till en lista med exakt samma objekt
  var i = 0;
  smhiDataR = [];

  while(smhiData.o[i] != null){
    var singleObj = {};

    var time = smhiData.o[i].date.date.toISOString();
    
    singleObj['temp'] =+ smhiData.o[i].temp;
    singleObj['date'] = time;

    smhiDataR.push(singleObj);
    i++;

  }
  updateGraph(smhiDataR);

}


function updateGraph(smhiDataR){
    smhiDataR.forEach(function(d){
      d.date = format.parse(d.date);
      d.value =+ d.temp;
    });


    //TODO:
    //Denna ska fungera, men den gör inte riktigt det än.. Av någon anledning blir antingen d.y0 eller d.y noll
    //Just nu är det hårdkodat nedanför..
    //x.domain([0, d3.extent(smhiDataR, function(d) { return d.y0 + d.y ; })]);

    var layers = stack(nest.entries(smhiDataR));
    x.domain([-30, 30]);
    y.domain(d3.extent(smhiDataR, function(d){ return d.date; }));
    //y.domain([0,50]);

    svg.selectAll(".layer")
          .data(layers)
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
      return j != i ? 0.6 : 1;
  })})

  .on("mousemove", function(d, i) {
      mousex = d3.mouse(this); //Returns the x and y coordinates of the current d3.event,
      							//The coordinates are returned as a two-element array [x, y].
      mousex = mousex[1];
      var invertedx = y.invert(mousex); //ändrade från x till y, hände inget
      //invertedx = invertedx.getTime();
      //scale.invert(y) Returns the date in the input domain x for the corresponding value in the output range y
      //Vi vill ha input domain y i corresponding output range x
      
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
      
    })
/*    .on("mouseout", function(d, i) {
     svg.selectAll(".layer")
      .transition()
      .duration(250)
      .attr("opacity", "1");
      d3.select(this)
      .classed("hover", false)
      .attr("stroke-width", "0px"), tooltip.html( "<p>" + d.key + "<br>" + pro + "</p>" ).style("visibility", "hidden");
  })*/

	//den nya horisontella linjen
	var horizontal = d3.select(".chart")
            .append("div")
            .attr("class", "remove")
            .style("position", "absolute")
            .style("z-index", "19")
            .style("width", "110px")
            .style("height", "2px")
            .style("top", "300px")
            .style("bottom", "30px")
            .style("left", "50vw")
            .style("background", "#3c3c3c");
            
    var vertical = d3.select(".chart")
            .append("div")
            .attr("class", "remove")
            .style("position", "absolute")
            .style("z-index", "19")
            .style("width", "1px")
            .style("height", "380px")
            .style("top", "10px")
            .style("bottom", "30px")
            .style("left", "0px")
            .style("background", "#fff");

		//ändra så att pinnen går upp och ner istället för höger och vänster
            d3.select(".chart")
      .on("mousemove", function(){ 
         mousex = d3.mouse(this);
         mousex = mousex[0] + 5;
         horizontal.style("left", mousex + "px" )})
      .on("mouseover", function(){  
         mousex = d3.mouse(this);
         mousex = mousex[0] + 5;
         horizontal.style("left", mousex + "px")});

    //TODO:
    //Här lägger man till om den rör sig över ".chart"-en
    //d3.select(".chart")
    //  .on("mousemove", function(){ osv.. 


  }
