let path = "C:/Users/19930/Desktop/xoxo/"

let title = "\
<div id='photo'></div>\
<div id='title_ch'>林悠然&nbsp;&nbsp; <span id='title_oc'></span></div>\
<div id='title_en'>Youran Lin</div>\
"

let menu = "\
<div class='menuitem'>\
  <a href='" + path + "index.html'>Home</a>\
</div>\
 | \
<div class='menuitem'>\
  <a href='" + path + "about.html'>About</a>\
</div>\
 | \
<div class='menuitem'>\
  <a href='" + path + "blog.html'>Blog</a>\
</div>\
 | \
<div class='menuitem'>\
  <a href='" + path + "contact.html'>Contact</a>\
</div>\
"

let footer = "\
&copy; " + new Date().getFullYear() + ", Youran Lin\
"

document.getElementById('title').innerHTML = title
document.getElementById('menu').innerHTML = menu
document.getElementById('footer').innerHTML = footer