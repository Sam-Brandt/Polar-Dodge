--Sam Brandt
--Basic module with the primary purpose of making it easy to close
--a graphics window and with the general purpose of abstracting boilerplate
--UI code that's common for the draw library

close={}
close.bgc=draw.white
close.running=false
close.slowth=1
close.coords={x=0,y=0}
close.touched=false
close.cursorshown=false
close.camera={x=0,y=0}
local a,b=0,0
local color={1,0,0,0.7}
local ending=false

function close.update()
end

function close.render()
end

local function init()
   draw.setscreen(1)
   draw.showtitle(false)
   close.running=true
end

function close.begin(x,y)
end
function close.during(x,y)
end
function close.done(x,y)
end

function close.mbegin(t)
end
function close.mduring(t)
end
function close.mdone(t)
end

function draw.touchbegan(t)
   if t[1].x>=close.width-40 and t[1].y<=40 then
      ending=true
      color={1,0.5,0.5,0.7}
   else
      close.coords.x=t[1].x
      close.coords.y=t[1].y
      a,b=t[1].x,t[1].y
      close.touched=true
      close.begin(t[1].x,t[1].y)
      close.mbegin(t)
   end
end
function draw.touchmoved(t)
   if not ending then
      close.coords.x=t[1].x
      close.coords.y=t[1].y
      close.camera.x=close.camera.x+t[1].x-a
      close.camera.y=close.camera.y+t[1].y-b
      a,b=t[1].x,t[1].y
      close.during(t[1].x,t[1].y)
      close.mduring(t)
   end
end
function draw.touchended(t)
   if t[1].x>=close.width-40 and t[1].y<=40 and ending then
      close.running=false
   elseif ending then
      ending=false
      color={1,0,0,0.7}
   else
      close.touched=false
      close.done(t[1].x,t[1].y)
      close.mdone(t)
   end
end

local function nupdate()
   close.width,close.height=draw.getport()
   close.update()
end

local function nrender()
   draw.beginframe()
   draw.clear(close.bgc)
   close.render()
   draw.fillrect(close.width-40,0,close.width,40,color)
   draw.rect(close.width-40,0,close.width,40,{0,0,0,0.5})
   draw.line(close.width-40,0,close.width,40,{0,0,0,0.5})
   draw.line(close.width-40,40,close.width,0,{0,0,0,0.5})
   if close.touched and close.cursorshown then
      draw.fillcircle(close.coords.x,close.coords.y,10,{0.5,0.5,0.5,0.5})
   end
   draw.endframe()
end

function close.main()
   init()
   while close.running do
      nupdate()
      nrender()
      draw.doevents()
      sleep(10*close.slowth)
   end
end
