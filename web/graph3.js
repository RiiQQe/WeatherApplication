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
  console.log("init..");
  format = d3.time.format.utc("%Y-%m-%dT%H:%M:%S.%LZ");
  //TODO:
  //Make these responsive
  margin = {top: 20, right: 40, bottom: 30, left: 30};
  width = document.body.clientWidth - margin.left - margin.right;
  height = document.body.clientHeight - margin.top - margin.bottom;


  //TODO: 
  //When yrData is added, add one color.
  colorrange = ["#B30000", "#E34A33"];
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
              .ticks(d3.time.days);

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
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

}

function setParameters(smhiData){
  console.log("setParameters...");
  //TODO: 
  //Denna delen känns lite konstig, översätter från en list med obj
  //till en lista med exakt samma objekt
  var i = 0;
  smhiDataR = [];
  console.log("HAAAAAAR");
  smhiDataR.forEach(function(d){
    console.log("ifall detta kommer ut flera gånger så funkar de inte så bra... ");
  });

  while(smhiData.o[i] != null){
    var singleObj = {};

    var time = smhiData.o[i].date.date.toISOString();

    singleObj['temp'] =+ smhiData.o[i].temp;
    singleObj['date'] = time;

    smhiDataR.push(singleObj);
    i++;

  }
  console.log("number of elements: " + i );
  updateGraph(smhiDataR);

}


function updateGraph(smhiDataR){
  console.log("updateGraph...");
    smhiDataR.forEach(function(d){
      d.date = format.parse(d.date);
      d.value =+ d.temp;
    });

    console.log(" Temperature : " + smhiDataR[1].temp);

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
      .attr("transform", "translate(" + (width) + ", 0)")
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
      mousex = d3.mouse(this);
      mousex = mousex[0];
      var invertedx = x.invert(mousex);
      //invertedx = invertedx.getTime();
      
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
    .on("mouseout", function(d, i) {
     svg.selectAll(".layer")
      .transition()
      .duration(250)
      .attr("opacity", "1");
      d3.select(this)
      .classed("hover", false)
      .attr("stroke-width", "0px"), tooltip.html( "<p>" + d.key + "<br>" + pro + "</p>" ).style("visibility", "hidden");
  })

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

            d3.select(".chart")
      .on("mousemove", function(){ 
         mousex = d3.mouse(this);
         mousex = mousex[0] + 5;
         vertical.style("left", mousex + "px" )})
      .on("mouseover", function(){  
         mousex = d3.mouse(this);
         mousex = mousex[0] + 5;
         vertical.style("left", mousex + "px")});

    console.log("GRAPH SHOULD HAVE BEEN UPDATED");
    //TODO:
    //Här lägger man till om den rör sig över ".chart"-en
    //d3.select(".chart")
    //  .on("mousemove", function(){ osv.. 


  }
