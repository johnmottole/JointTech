var express = require('express');
var app = express();
var router = express.Router();
  
var views = __dirname + '/views/';
var public = __dirname + '/public/';
var path = require('path');
  


app.use('/',router);

app.use(express.static(path.join(__dirname, 'public')));


//HTML FILES
router.get('/',function(req, res){
  res.sendFile(views + 'login.html');
});

router.get('/dash',function(req, res){
  res.sendFile(views + 'dash.html');
});
  
router.get('/profile',function(req, res){
  res.sendFile(views + 'profile.html');});
  
router.get('/about',function(req, res){
  res.sendFile(views + 'about.html');
});



//JAVASCRIPT FILES
router.get('/js',function(req, res){
  res.sendFile(public + 'js/index.js');
});

//CSS FILES

router.get('/css',function(req, res){
  res.sendFile(public + 'css/index.css');
});

router.get('/img',function(req, res){
  res.sendFile(public + 'img/logo.png');
});



app.use('*',function(req, res){
  res.send('Error 404: Not Found!');
});
  
app.listen(3000,function(){
  console.log("Server running at Port 3000");
});