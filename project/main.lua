-- ГРАФство. Процедурно генерируемый лабиринт
-- ws07 мастерская № 7. ЛШЮП 2019

function love.load()
    love.window.setTitle("Граф ДРАКУЛА. Мастерская № 7. ЛШЮП 2019. Управление WASD и Tab")
    love.graphics.setDefaultFilter("nearest", "nearest") -- чтоб не сглаживались спрайты при отрисовке и оставались пиксельными
	source = love.audio.newSource( "sound/13.ogg", "stream")
	Die = love.audio.newSource( "sound/Dark Souls - You Died Sound Effect.mp3", "stream")
    colors = require "colors"    -- для совместимости разных версий Love
    inspect = require "inspect"    -- для печати в консоли содержимого таблиц
    gamera = require "gamera" -- библиотека камеры (показывать фрагмент уровня)
    sprite = require "sprite" -- загрузка картинок, рисование спрайтов
    collide = require "collide" --
    control = require "control"    -- управление с клавиатуры
    draw = require "draw"
    gra = require "generate"
    roomCollision = require "roomCollision"
    drawMiniMap = require "drawMiniMap"
    spawn = require "spawn"
    monster = require "monster"
    loot = require "loot"
    DoorsOfRoom = {}        
    --загрузка ресурсов
    heroSprite = newSpr("spr/mainHero", 50, 50, 0.3, 4, 3, { 1, 2, 3, 2 })
    bossSprite = newSpr("spr/dracula", 31, 80, 0.3, 4, 3, { 1, 2, 3, 2 })

    --монстры
    skeletSprite = newSpr("spr/mobSkelet", 51, 51, 0.4, 4, 1, { 1 })
    enemyUnknownSprite = newSpr("spr/enemyUnknown", 51, 51, 23, 1, 1)
    --вещи
    woodTable = newSpr("spr/woodTable", 50, 50, 0, 1, 1, nil)
    candle = newSpr("spr/candles", 30, 30, 0.2, 1, 2, { 1, 2 })
    MP = newSpr("spr/item.MP", 31, 31, 1, 1, 1)
    Quiver1 = newSpr("spr/item.Quiver1", 31, 31, 1, 1, 1)
    Shield1 = newSpr("spr/item.Shield1", 31, 31, 1, 1, 1)
    Ax1 = newSpr("spr/itemAx1", 31, 31, 1, 1, 1)
    Bow1 = newSpr("spr/itemBow1", 31, 31, 1, 1, 1)
    HP1 = newSpr("spr/itemHP1", 31, 31, 1, 1, 1)
    LongSword1 = newSpr("spr/itemLongSword1", 31, 31, 1, 1, 1)
    Rod1 = newSpr("spr/itemRod1", 31, 31, 1, 1, 1)
    Rod2 = newSpr("spr/itemRod2", 31, 31, 1, 1, 1)
    Shield2 = newSpr("spr/itemShield2", 31, 31, 1, 1, 1)
    Shield3 = newSpr("spr/itemShield3", 31, 31, 1, 1, 1)
    Sword1 = newSpr("spr/itemSword1", 31, 31, 1, 1, 1)
    Sword2 = newSpr("spr/itemSword2", 31, 31, 1, 1, 1)
    IronHelmet = newSpr("spr/itemIronHelmet", 31, 31, 1, 1, 1)
    IronJacket = newSpr("spr/itemIronJacket", 31, 31, 1, 1, 1)
    IronPants = newSpr("spr/itemIronPants", 31, 31, 1, 1, 1)
    MailHelmet = newSpr("spr/itemMailHelmet", 31, 31, 1, 1, 1)
    MailJacket = newSpr("spr/itemMailJacket", 31, 31, 1, 1, 1)
    MailPants = newSpr("spr/itemMailPants", 31, 31, 1, 1, 1)

    Gold = newSpr("spr/itemGold", 31, 31, 1, 1, 1)
    Key = newSpr("spr/itemKey", 31, 31, 1, 1, 1)
    KeyBlue = newSpr("spr/itemKeyBlue", 31, 31, 1, 1, 1)
    KeyGreen = newSpr("spr/itemKeyGreen", 31, 31, 1, 1, 1)
    KeyRed = newSpr("spr/itemKeyRed", 31, 31, 1, 1, 1)
	
	YouWin = newSpr("spr/YOU WIN", 298,250, 1, 1, 1)
	YouDied = newSpr("spr/YOU DIED", 265,231, 1, 1, 1)
	ModelFloor = newSpr("spr/modelFloor1",403,403,1,1,1)

    chans = { { Key, 'Key', 0 },
              { KeyBlue, 'KeyBlue', 0 },
              { KeyGreen, 'KeyGreen', 0 },
              { KeyRed, 'KeyRed', 0 },
              { Gold, 'Gold', 0 },
              { MP, 'MP', 0 },
              { Quiver1, 'Quiver1', 0 },
              { Shield1, 'Shield1', 5 },
              { Ax1, 'Ax1', 5 },
              { Bow1, 'Bow1', 6 },
              { HP1, 'HP1', 15 },
              { LongSword1, 'LongSword1', 6 },
              { Rod1, 'Rod1', 6 },
              { Rod2, 'Rod2', 6 },
              { Shield2, 'Shield2', 6 },
              { Shield3, 'Shield3', 6 },
              { Sword1, 'Sword1', 6 },
              { Sword2, 'Sword2', 6 },
              { IronHelmet, 'IronHelmet', 3 },
              { IronJacket, 'IronJacket', 3 },
              { IronPants, 'IronPants', 3 },
              { MailHelmet, 'MailHelmet', 6 },
              { MailJacket, 'MailJacket', 6 },
              { MailPants, 'MailPants', 6 } }

    rand = {}
    for ch = 1, #chans do
        for f = 1, chans[ch][3] do
            rand[#rand + 1] = chans[ch]
        end
    end


	state={
	Shield1={Def=10 },
	Ax1={Range=10,Damage=10,Cd=0},
	Bow1={Range=50,Damage=-10,Cd=0.5},
	LongSword1={Range=20,Damage=10,Cd=0},
	Rod1={Range=20,Damage=15,Cd=1},
	Rod2={Range=20,Damage=30,Cd=1.5},
	Shield2={Def=10 },
	Shield3={Def=20 },
	Sword1={Range=10,Damage=20,Cd=0},
	Sword2={Range=10,Damage=30,Cd=0},
	IronHelmet={Def=15 },
	IronJacket={Def=15 },
	IronPants={Def=15 },
	MailHelmet={Def=10 },
	MailJacket={Def=10 },
	MailPants={Def=10 }
	}
    math.randomseed(os.time())
    Ls = 31
    ws = 3
    size = 403 + 2 * ws
    n = 10
    mapSize = love.graphics.getHeight() / n
    doorSize = mapSize / 5
	gameMode=1
    -- таблица главного героя
    Rooms, graph, Doors = gra.generate()
    id = max_vert1
    for p = 1, #Rooms do
        --print(p,castl[p].tip)
        if Rooms[p].tip == 'treasure' then
            for i = 1, math.random(2,4), 1 do
                spawn.AddLotLoot(p, Rooms)
            end
        end
    end
    --print(inspect( castl, { depth = 4 } ) )
	timer=0
	mous1=false
	pressed=false
    Hero = { bazDef=0, Def=0,id = id, cellX = id % n, cellY = math.floor(id / n) + 1, name = "Hero", Type = "circle", mode = "line", sprite = heroSprite, x = collide.XYFromID(max_vert1)[1] * size + size / 2, y = (collide.XYFromID(max_vert1)[2] + 2) * size + size / 2, radius = 10, colour = "transparent",HP=500,hit={bazCd=1,bazRadius=30,bazDamage=20,cd=1,visCd=0.2,radius=30,colour="green",visibility=false,x=0,y=0,Type="circle",damage=20},lastTime=0}
	Inventory = {}
	equipment={shield='',sword='',helmet='',jacket='',pants=''}
    Objects = { Hero }
	for r=1,#Rooms do
	   	if Rooms[r].use then
			if Rooms[r].tip=='' then
				local m = { { 'Ghost', 5 },
                { 'Wolf', 10 },
                { 'Skelet', 20 },
                { 'Mushroom', 30 },
                { 'Snake', 15 },
                { 'Slime', 20}}
					
			
				local mobs = {}
				for ch = 1, #m do
					for f = 1, m[ch][2] do
						mobs[#mobs + 1] = m[ch]
					end
				end
				for i=1,math.random(1,4) do
					monster.CreateMonster(r,mobs[math.random(1,100)][1])
				end
			end
			if Rooms[r].tip=='boss' then
				monster.CreateMonster(max_vert2, 'Drakula')
			end
			if Rooms[r].tip=='treasure' then
				m = { { 'Ghost', 5 },
                { 'Wolf', 10 },
                { 'Skelet', 20 },
                { 'Mushroom', 30 },
                { 'Snake', 15 },
                { 'Slime', 20}}
					
				mobs = {}
				for ch = 1, #m do
					for f = 1, m[ch][2] do
						mobs[#mobs + 1] = m[ch]
					end
				end
				for i=1,math.random(1,4) do
					monster.CreateMonster(r,mobs[math.random(1,100)][1])
				end
			end
		end
	end
    cam = gamera.new(0, 0, size * (n + 2), size * (n + 2))
    cam:setWindow(0, 0, love.graphics.getWidth(),love.graphics.getHeight())
    cam:setScale(1.6)
	--
end
function love.draw()
	if gameMode==1 then
		love.graphics.clear(0, 0, 0)
        colors.set("white")
		love.graphics.print("A - Left",0,0,0,5)
		love.graphics.print("W - Up",0,50,0,5)
		love.graphics.print("S - Down",0,100,0,5)
		love.graphics.print("D - Right",0,150,0,5)
		love.graphics.print("Space - Hit",0,200,0,5)
		love.graphics.print("Q - Pick a thing",0,250,0,5)
		love.graphics.print("Escape - Leave the game",0,300,0,5)
		love.graphics.print("Tab - Minimap and inventory",0,350,0,5)
		love.graphics.print("Press space to start the game",0,450,0,5)
		if love.keyboard.isDown("enter","space") then
			gameMode=2
		end
	elseif gameMode==2 then
        love.graphics.clear(0, 0, 0)
        if love.keyboard.isDown("tab") then
            drawMiniMap.drawMiniMap(Rooms)
            MousX, MousY = love.mouse.getPosition()
            if love.mouse.isDown(1) and MousX < love.graphics.getHeight() then
                Hero.cellX = math.floor(MousX / mapSize) + 2
                Hero.cellY = math.floor(MousY / mapSize) + 2
                Hero.id = (Hero.cellY - 1) * n + Hero.cellX
                Hero.x = Hero.cellX * size - size / 2
                Hero.y = Hero.cellY * size - size / 2
            end
        else
            cam:draw(function(l, t, w, h)
                draw.drawFloor()
                spawn.drawLoot(v, Rooms)
                colors.set("white")
                spawn.drawLoot(v, Rooms)
                love.graphics.print("FPS "..math.floor(love.timer.getFPS()), l, t)
		    	love.graphics.print("HP "..Hero.HP, l, t+10)
				love.graphics.print("Damage "..Hero.hit.damage, l, t+20)
				love.graphics.print("Defense "..Hero.Def, l, t+30)
				love.graphics.print("Range "..Hero.hit.radius, l, t+40)
				love.graphics.print("Cooldown "..Hero.hit.cd, l, t+50)
                draw.draw(Objects)
            end)
        end
		if Hero.HP<=0 then
			gameMode=3
		end
    elseif gameMode==3 then
		love.audio.play( Die )
		love.graphics.clear(0, 0, 0)
        colors.set("white")
		drawSpr(YouDied, love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	elseif gameMode==4 then
		love.graphics.clear(0, 0, 0)
        colors.set("white")
		drawSpr(YouWin, love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	end
end
function love.update(dt)
	love.audio.play( source )
	if gameMode~=1 then
		timer=timer+dt
		local lenObjects = #Objects
		for i = lenObjects, 1, -1 do
			if Objects[i].name == "wall" then
				table.remove(Objects, i)
			end
		end
		DoorsOfRoom = {}
		visited = {}
		Hero.cellX = (Hero.x - (Hero.x % size)) / size
		Hero.cellY = (Hero.y - (Hero.y % size)) / size
		Hero.id = (Hero.cellY - 1) * n + Hero.cellX
		Hero.hit.x,Hero.hit.y=Hero.x,Hero.y
		if Hero.hit.visibility==true and Hero.hit.visCd<timer-Hero.lastTime then
			Hero.hit.visibility=false
		end
		roomCollision.dfs(graph, Hero.id, n, Hero.cellX * size + size / 2, Hero.cellY * size + size / 2, size, 5, 3, "white")
		v = visited
		loot.takeTool()
		local A = roomCollision.neighbours(visited, graph)
		for i = 1, #A do
			visited = {}
			roomCollision.dfs(graph, A[i], n, (collide.XYFromID(A[i])[1] + 0) * size + size / 2, (collide.XYFromID(A[i])[2] + 2) * size + size / 2, size, 5, 3, { 50, 50, 50, 255 })
		end
		control.control({ "a", "w", "s", "d", "q", "e" }, Hero, 250 * dt, 100 * dt)
		monster.UpdateMonster(dt)
		Hero.Def=Hero.bazDef
		Hero.hit.damage=Hero.hit.bazDamage
		Hero.hit.cd=Hero.hit.bazCd
		Hero.hit.radius=Hero.hit.bazRadius
		Hero.Def,Hero.hit.damage,Hero.hit.radius,Hero.hit.cd=Hero.bazDef,Hero.hit.bazDamage,Hero.hit.bazRadius,Hero.hit.bazCd
		if equipment.sword~='' then
			Hero.hit.damage=Hero.hit.damage+state[equipment.sword].Damage
			Hero.hit.radius=Hero.hit.radius+state[equipment.sword].Range
			Hero.hit.cd=Hero.hit.cd+state[equipment.sword].Cd
		end
		if equipment.helmet~='' then
			Hero.Def=Hero.Def+state[equipment.helmet].Def
		end
		if equipment.shield~='' then
			Hero.Def=Hero.Def+state[equipment.shield].Def
		end
		if equipment.jacket~='' then
			Hero.Def=Hero.Def+state[equipment.jacket].Def
		end
		
		if equipment.pants~='' then
			Hero.Def=Hero.Def+state[equipment.pants].Def
		end--shield='',sword='',helmet='',jaket='',pants=''
		cam:setPosition(Hero.x, Hero.y)
	end
end