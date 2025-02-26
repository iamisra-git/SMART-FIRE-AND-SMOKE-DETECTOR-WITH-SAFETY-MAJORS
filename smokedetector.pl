
 

 %declaring the  facts as dynamic.
:-dynamic room/1.
:-dynamic temperature/2 . 
:-dynamic smoky/1 .
:-dynamic nonsmoky/1 .
:-dynamic door/2 . 
:-dynamic window/2 . 
:-dynamic color/2 . 
:-dynamic density/2 . 
:-dynamic damper/1.

% just to refer to facts used. 
%temperature(Room,Temp).
smoky(Room).
nonsmoky(Room).
%door(Condition,Room).
%window(Condition,Room).
%color(Color,smoke).
%density(Room,Z).
damper(Speed).

%! determining the type of smoke by the color  of the smoke

smoketype(light):-color(X,smoke),X == 'grey',write('THE SMOKE IS LIGHT COLOR'),nl.
smoketype(dark):-color(X,smoke),X == 'black',write('THE SMOKE IS BLACK COLOR'),nl.
smoketype(none):-color(X,smoke),X == 'none',write('THERE IS NO SMOKE'),nl.


%!   density to smoke should be this  in different cases of door and window.
amountofsmoke(closed_window_door,80).
amountofsmoke(closeopen_window_door,80). 
amountofsmoke(open_windows_door,50).
amountofsmoke(fire_tamed,20).
amountofsmoke(nosmoke,15). %if nosmoke.

%cases for doors and windows of a room.
both_close(this):-door(isclose,Room),window(isclose,Room).
door_open(this):-door(isopen,Room),window(isclose,Room).
window_open(this):-door(isclose,Room),window(isopen,Room).
both_open(this):-door(isopen,Room),window(isopen,Room).

%! possibilities of fire in a room based on density of smoke or the amount of smoke in the room  
possibility1(fire,Room):- smoky(Room),both_close(this),
						amountofsmoke(closed_window_door,Y),density(Room,Z), Z >= Y .
				
possibility2(fire,Room):- smoky(Room),
						 amountofsmoke(closeopen_window_door,Y),density(Room,Z), Z >= Y,door_open(this); window_open(this).
				
possibility3(fire,Room):- smoky(Room),both_open(this),
						 amountofsmoke(open_windows_door,Y),density(Room,Z), Z >= Y.

%if nofire.						
possibility4(fire,Room):- nonsmoky(Room),amountofsmoke(nosmoke,Y),density(Room,Z),Z =< Y,
                       both_open(this);door_open(this);window_open(this);both_close(this).
				


%fire in room if the temperature of the room is above the condition .
fire(Room):-temperature(Room,T),T>70 .

%if temperature less than 50 .
nofire(Room):-possibility4(fire,Room),temperature(Room,T),T<50, write('NO FIRE'),smoketype(none).


%! ring the alarm if the above possibility is satisfied and fire is true 
ring(thealarm,Room):- room(Room), Room \= toilet,fire(Room),
					write('**** ALARM ON IN*** '),write(Room),nl,possibility1(fire,Room); possibility2(fire,Room); possibility3(fire,Room).
					

%safetycheck.

%turning dampers on in different speed. 
damperon(Room):- room(Room),ring(thealarm,Room),smoketype(light),
				damper(Speed), Speed =50 ,
				write('TURNING ON DAMPER TO SPEED'),write(Speed),nl.
				
damperon(Room):- room(Room),ring(thealarm,Room),smoketype(dark),
				damper(Speed),Speed =100 ,
				write('TURNING ON DAMPER TO SPEED'),write(Speed),nl.

%since no alarm can be fitted in the toilet .			
damperon(Room):- room(Room),Room == toilet,possibility1(fire,Room); possibility2(fire,Room); possibility3(fire,Room),
				fire(Room),smoketype(dark),damper(Speed),Speed =100 ,
				write('TURNING ON DAMPER TO SPEED'),write(Speed),nl.
				
damperon(Room):- room(Room),Room == toilet,possibility1(fire,Room); possibility2(fire,Room); possibility3(fire,Room),
				fire(Room),smoketype(light),damper(Speed),Speed =50 ,
				write('TURNING ON DAMPER TO SPEED'),write(Speed),nl.
							
				
%control the spreeding of fire by closing or opening the doors and windows .
control_fire(Room):-both_open(this),smoky(Room),retractall(door(Condition,Room)),retractall(window(Condition,Room)), 
					Do = 'isclose',assert(door(Do,Room)),assert(window(Do,Room)),
					format('NOW THE DOOR OF ~w is ~w',[Room,Do]),nl,door_open(this); window_open(this).

control_fire(Room):-door_open(this),smoky(Room),retractall(door(Condition,Room)),
					Do = 'isclose',assert(door(Do,Room)),
					format('NOW THE DOOR  AND WINDOW OF ~w is ~w',[Room,Do]),nl,smoketype(light);smoketype(dark).
					
control_fire(Room):-window_open(this),smoky(Room),retractall(window(Condition,Room)),
					Do = 'isclose',assert(window(Do,Room)),
					format('NOW THE  WINDOW OF ~w is ~w',[Room,Do]),nl,smoketype(light);smoketype(dark).
									
					
control_fire(Room):- both_close(this),smoky(Room),smoketype(light);smoketype(dark),
					write('THE DOOR AND THE WINDOW ARE ALREADY CLOSED'),nl.

%turning dampers off to prevent furniture damages .
damperoff(Room,Speed):-retractall(density(Room,Z)),assert(density(Room,Z)), Z=20,amountofsmoke(fire_tamed,Rate),Z == Rate,damper(Speed),Speed = 0,format('SPEED LOWERING TO ~0f',[Speed]),smoky(Room),smoketype(light);smoketype(dark).


for_queries(this):-
			retractall(room(Room)),
			retractall(temperature(Room,T)),
			retractall(smoky(Room)),
			retractall(door(Condition,Room)),
			retractall(window(Condition,Room)),
			retractall(color(Color,smoke)),
			retractall(density(Room,Z)),
			

			write('____________________________________________________________________________'),nl,
			write('                   SMART SMOKE DETECTING ASSISTANT                          '),nl,
			write('WHICH ROOM ARE YOU ENTERING DATA ABOUT?'),nl,
			read(Room),
			write('WHAT IS THE TEMPERATURE OF THE ROOM?'),nl,
			read(Temparature),
			write('IS THE DOOR OPEN OR CLOSE?'),nl,
			read(Door),
			write('IS THE WINDOW OPEN OR CLOSE'),nl,
			read(Window),
			write('IS THE SMOKE GREY OR BLACK IN COLOR'),nl,
			read(Color),
			write('WHAT IS THE DENSITY OF THE SMOKE IN ROOM'),nl,
			read(Density),
			write('____________________________________________________________________________'),nl,
			
			assert(room(Room)),
			assert(temperature(Room,Temparature)), 
			( (Density >10) -> assert(smoky(Room));  %if density is greater than 10 room is smoky.          
			  (Density < 11) -> assert(nonsmoky(Room)) ),   %else non smoky.
			assert(door(Door,Room)),
			assert(window(Window,Room)),
			assert(color(Color,smoke)),
			assert(density(Room,Density)),
			
			write('____________________________________________________________________________'),nl,
			
			%if else for when entered toilet .
			
			( (Room == toilet) -> ( (Density < 11) -> nofire(Room),write('nofire');     %predicate call this if density less than 11 .
									  ((Density > 10) -> damperon(Room),control_fire(Room),  %else call these .
									damperoff(Room,Speed)) ); 
			
			(Room \= toilet) -> ( (Density < 11) -> nofire(Room);         %predicate call this if density less than 11 .
									 ((Density > 10) -> ring(thealarm,Room),damperon(Room),         %else call these .
									control_fire(Room),damperoff(Room,Speed)) )
		
			).
			
			
			
			
			
			





















