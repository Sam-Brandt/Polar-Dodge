--Sam Brandt
--Game Logic and Graphics for "Polar Dodge", a bullet hell with
--very unintuitive controls!

require "CloseButton"
transgray={0,0,0,0.1}
lx,ly=0,0
cx,cy=0,0
theta=0
r=0
speed=3
action=0
t=0
radius=500
rimspeed=2
health=10
level=1
rimtheta=0
rtf=5
bulfreq=10
spikefreq=0
bullets={}
exps={}
function rangeangle(t)
   t=t%(2*math.pi)
   if t<0 then
      t=t+2*math.pi
   end
   return t
end
function calcaction(x,y)
   if y>=x*320/568 and y<=320-x*320/568 then
      action=1
   elseif y<=x*320/568 and y>=320-x*320/568 then
      action=2
   elseif y<=x*320/568 and y<=320-x*320/568 then
      action=3
   else
      action=4
   end
end
function makebullet(hs)
   local angle=math.random(0,629)/100
   local vangle=angle+math.pi+math.random(-70,70)/100
   local potmode=math.random(1,50)
   local mode=0
   if potmode>=48 and potmode<=49 then
      mode=1
   elseif potmode==50 then
      mode=2
   end
   if mode==0 then
      if math.random(1,100)<=spikefreq*100 then
         mode=3
      end
   end
   bullets[#bullets+1]={x=(radius+100)*math.cos(angle),y=(radius+100)*math.sin(angle),vx=hs*math.cos(vangle),vy=hs*math.sin(vangle),living=false,cd=0,mode=mode}
end
function drawshwubbard(x,y)
   local s=2.5*math.sin(0.1*t)
   draw.fillellipse(x-7-s,y-7+s,x+7+s,y+7-s,{1,0.70+s/10,0,1})
end
function close.begin(x,y)
   if x>500 and y>270 then
      pressed=true
   else
      calcaction(x,y)
   end
end
function close.during(x,y)
   if not pressed then
      calcaction(x,y)
   end
end
function close.done(x,y)
   if x>500 and y>270 and pressed and rtf>0 then
      pressed=false
      exps[#exps+1]={lx,ly,200}
      rtf=rtf-1
   end
   action=0
end
function close.update()
   t=t+1
   if t%1000==0 then
      if spikefreq<1 then
         spikefreq=spikefreq+0.05
      end
      level=level+1
      health=health+2
      if health>10 then
         health=10
      end
      if level%5==0 and level<26 then
         bulfreq=bulfreq-1
      end
      for i=1,25 do
         makebullet(2)
      end
   end
   local tbd={}
   local etb=nil
   for i=1,#exps do
      exps[i][3]=exps[i][3]-2
      if exps[i][3]<=0 then
         etb=i
      end
   end
   if etb~=nil then
      table.remove(exps,etb)
   end
   for i=1,#bullets do
      if (bullets[i].x-lx)^2+(bullets[i].y-ly)^2<=17^2 and bullets[i].cd==0 then

         if bullets[i].mode==0 then
            health=health-1
         elseif bullets[i].mode==1 then
            if health<10 then
               health=health+1
            end
         elseif bullets[i].mode==2 then
            rtf=rtf+1
            tbd[#tbd+1]=i
         elseif bullets[i].mode==3 then
            health=health-2
         end
         bullets[i].cd=30
      end
      for j=1,#exps do
         if (bullets[i].x-exps[j][1])^2+(bullets[i].y-exps[j][2])^2<=(200-exps[j][3]+6)^2 and (bullets[i].mode==0 or bullets[i].mode==3) then
            tbd[#tbd+1]=i
         end
      end
   end
   if health<=0 then
      print("YOU DIED! You reached level "..level..".")
      close.running=false
   end
   rimtheta=rimtheta+0.001*rimspeed
   cx=radius*math.cos(rimtheta)
   cy=radius*math.sin(rimtheta)
   theta=math.atan2(ly-cy,lx-cx)
   r=math.sqrt((cx-lx)^2+(cy-ly)^2)
   if action==1 and r~=0 then
      theta=theta-speed/r
   elseif action==2 and r~=0 then
      theta=theta+speed/r
   elseif action==3 then
      r=r+speed
   elseif action==4 then
      r=r-speed
   end
   wx=r*math.cos(theta)
   wy=r*math.sin(theta)
   lx=wx+cx
   ly=wy+cy
   if lx^2+ly^2>(radius-10)^2 then
      local dist=math.sqrt(lx^2+ly^2)
      lx=(radius-10)*lx/dist
      ly=(radius-10)*ly/dist
   end
   for i=1,#bullets do
      bullets[i].x=bullets[i].x+bullets[i].vx
      bullets[i].y=bullets[i].y+bullets[i].vy
      if bullets[i].cd>0 then
         bullets[i].cd=bullets[i].cd-1
      end
      if bullets[i].x^2+bullets[i].y^2<radius^2 and not bullets[i].living then
         bullets[i].living=true
      elseif bullets[i].x^2+bullets[i].y^2>=(radius+7)^2 and bullets[i].living then
         tbd[#tbd+1]=i
      end
   end
   local sub=0
   for i=1,#tbd do
      table.remove(bullets,tbd[i-sub])
      sub=sub+1
   end
   if t%bulfreq==0 then
      makebullet(1)
   end
end
function close.render()
   for i=0,10 do
      draw.line(0,32*i-(ly+32)%32,568,32*i-(ly+32)%32,draw.blue)
   end
   for i=0,math.ceil(10*568/320) do
      draw.line(32*i-(lx+32)%32,0,32*i-(lx+32)%32,320,draw.blue)
   end
   draw.circle(284-lx,160-ly,radius,draw.black)
   draw.line(284,160,284+cx-lx,160+cy-ly,draw.red)
   draw.fillcircle(284+cx-lx,160+cy-ly,5,draw.black)
   for i=1,#bullets do
      local bx=284+bullets[i].x-lx
      local by=160+bullets[i].y-ly
      if bullets[i].mode==0 then
         draw.fillcircle(bx,by,7,draw.gray)
      elseif bullets[i].mode==1 then
         draw.fillrect(bx-7,by-3,bx+7,by+3,draw.red)
         draw.fillrect(bx-3,by-7,bx+3,by+7,draw.red)
      elseif bullets[i].mode==2 then
         drawshwubbard(bx,by)
      elseif bullets[i].mode==3 then
         local px=284-bx
         local py=160-by
         local dist=math.sqrt(px^2+py^2)
         px=px/dist
         py=py/dist
         draw.filltriangle(bx+7*px,by+7*py,bx-6*px-4*py,by-6*py+4*px,bx-6*px+4*py,by-6*py-4*px,draw.purple)
      end
   end
   for i=1,#exps do
      draw.circle(284+exps[i][1]-lx,160+exps[i][2]-ly,200-exps[i][3],draw.red)
   end
   draw.fillcircle(284,160,10,draw.green)
   draw.fillrect(10,290,10+15*health,310,draw.red)
   draw.rect(10,290,160,310,draw.black)
   draw.fillrect(10,30,10+(t%1000)*80/1000,40,{0,1,0.2,1})
   draw.rect(10,30,90,40,draw.black)
   local color=draw.black
   if rtf<=0 then
      color=draw.darkgray
   end
   draw.fillrect(510,288,568,320,color)
   drawshwubbard(528,305)
   draw.string("x"..rtf,543,295,draw.white)
   draw.string("Level "..level,10,5,draw.black)
   if action==1 then
      draw.filltriangle(0,0,0,320,284,160,transgray)
   elseif action==2 then
      draw.filltriangle(568,0,568,320,284,160,transgray)
   elseif action==3 then
      draw.filltriangle(568,0,0,0,284,160,transgray)
   elseif action==4 then
      draw.filltriangle(0,320,568,320,284,160,transgray)
   end
   draw.fillrect(568,0,800,500,draw.black)
   draw.fillrect(0,320,800,500,draw.black)
end
close.main()