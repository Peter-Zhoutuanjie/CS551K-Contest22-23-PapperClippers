// Agent bob in project MAPC2018.mas2j
{ include("strategy/identification.asl", identification) }
{ include("strategy/exploration.asl", exploration) }
{ include("strategy/task.asl", task) }
/* Initial beliefs and rules */       
location(0,0).
exploration_mode(on).
find_blocks(true).

/* Initial goals */            
                           
!start.                

/* Plans */

+!start : true <- 
	.print("hello massim world.").

+actionID(X) : exploration_mode(on) <- 
	.random(RandomNumber);
	!explore(RandomNumber).

+actionID(ID) : exploration_mode(off) & block(Dir,Details) & goal_base(n,X,Y) <- 
	.print("going to the goal postition nnnnnnnnnnn");
	!move_on(X,Y).
+actionID(ID) : exploration_mode(off) & block(Dir,Details) & goal_base(c,X,Y) <- 
	.print("going to the goal postition ccccccccccc");
	!move_on(X,Y).
	
// agent explore the world
+!explore(RandomNumber): true<-
	!move(RandomNumber);
	.print("agent explore the world").

+!move(RandomNumber): (RandomNumber<0.25) <-
	+location(X,Y+1);
	move(n);
	.print("agent move north").
+!move(RandomNumber): (RandomNumber>=0.25 & RandomNumber<0.5) & location(X,Y) <-
	+location(X+1,Y);       
	move(e);
	.print("agent move east").
+!move(RandomNumber): (RandomNumber>=0.5 & RandomNumber<0.75) & location(X,Y)<-
	+location(X,Y-1);        
	move(s);
	.print("agent move south").
+!move(RandomNumber): (RandomNumber>=0.75 & RandomNumber<1) & location(X,Y)<-
	+location(X-1,Y); 
	move(w);
	.print("agent move west").

	

+!move_to(X,Y): (X < -1)<-
	move(w).
+!move_to(X,Y): (X > 1)<-
	move(e).
+!move_to(X,Y): (Y < 0) & ((X == 1) | (X == -1)) <-
	move(n).
+!move_to(X,Y): (Y > 0) & ((X == 1) | (X == -1)) <-
	move(s).
+!move_to(X,Y): (Y < -1)<-
	move(s).
+!move_to(X,Y): (Y > 1)<-
	move(n).
+!move_to(X,Y): (Y < 0) & ((X == 1) | (X == -1)) <-
	move(n).
+!move_to(X,Y): (Y > 0) & ((X == 1) | (X == -1)) <-
	move(s).
-!move_to(X,Y): (X == 1) & (Y == 0) <- 
	request(e).
-!move_to(X,Y): (X == -1) & (Y == 0) <- 
	request(w).
-!move_to(X,Y): (X == 0) & (Y == 1) <- 
	request(n).
-!move_to(X,Y): (X == 0) & (Y == -1) <- 
	request(s).

+!move_on(X,Y): (X < 0)<-
	move(w).
+!move_on(X,Y): (X > 0)<-
	move(e).
+!move_on(X,Y): (X == 0) & (Y > 0)<-
	move(n).
+!move_on(X,Y): (X == 0) & (Y < 0)<-
	move(s).
+!move_on(X,Y): (X == 0) & (Y == 0)<-
	+exploration_mode(off).

// see a dispenser in distance
+thing(X, Y, Type, Details) : (Type == dispenser) &  not (X == 1) & not (Y == 0) & find_blocks(true) <-
	!move_to(X,Y);
	.print("see a dispenser in distance").
+thing(X, Y, Type, Details) : (Type == dispenser) &  not (X == -1) & not (Y == 0) & find_blocks(true) <-
	!move_to(X,Y);
	.print("see a dispenser in distance").
+thing(X, Y, Type, Details) : (Type == dispenser) &  not (X == 0) & not (Y == 1) & find_blocks(true) <-
	!move_to(X,Y);
	.print("see a dispenser in distance").
+thing(X, Y, Type, Details) : (Type == dispenser) &  not (X == 0) & not (Y == -1) & find_blocks(true) <-
	!move_to(X,Y);
	.print("see a dispenser in distance").

// see a dispenser next to agent
+thing(X, Y, Type, Details) : (Type == dispenser) & (X == -1) & (Y == 0) & find_blocks(true)<-
	request(w);
	.print("see a dispenser next to agent").
+thing(X, Y, Type, Details) : (Type == dispenser) & (X == 1) & (Y == 0) & find_blocks(true)<-
	request(e);
	.print("see a dispenser next to agent").
+thing(X, Y, Type, Details) : (Type == dispenser) & (X == 0) & (Y == -1) & find_blocks(true)<-
	request(s);
	.print("see a dispenser next to agent").
+thing(X, Y, Type, Details) : (Type == dispenser) & (X == 0) & (Y == 1) & find_blocks(true)<-
	request(n);
	.print("see a dispenser next to agent").

// attach a block
+thing(X, Y, Type, Details) : (Type == block) & (X == 1) & (Y == 0) & find_blocks(true) <- 
	attach(e);
	-+find_blocks(false);
	+block(e,Details);
	.print("attach a block").
+thing(X, Y, Type, Details) : (Type == block) & (X == -1) & (Y == 0) & find_blocks(true) <- 
	attach(w);
	-+find_blocks(false);
	+block(w,Details);
	-thing(X, Y, Type, Details);
	.print("attach a block").
+thing(X, Y, Type, Details) : (Type == block) & (X == 0) & (Y == 1) & find_blocks(true) <- 
	attach(n);
	-+find_blocks(false);
	+block(n,Details);
	-thing(X, Y, Type, Details);
	.print("attach a block").          
+thing(X, Y, Type, Details) : (Type == block) & (X == 0) & (Y == -1) & find_blocks(true) <- 
	attach(s);
	-+find_blocks(false);
	+block(s,Details);
	-thing(X, Y, Type, Details);
	.print("attach a block").

+attached(Y): true <-
	-+exploration_mode(on).

// agent see a goal
+goal(X,Y): block(Dir,Details)<-  
	-+exploration_mode(off);
	+goal_base(n,X,Y).

+goal_base(Pos,X,Y): goal_base(Pos,X,Y) & goal_base(Pos,X-1,Y)<-
	-+goal_base(c,X-1,Y).
+goal_base(Pos,X,Y): goal_base(Pos,X,Y) & goal_base(Pos,X+1,Y)<-
	-+goal_base(c,X+1,Y).
+goal_base(Pos,X,Y): goal_base(Pos,X,Y) & goal_base(Pos,X,Y-1)<-
	-+goal_base(c,X,Y-1).
+goal_base(Pos,X,Y): goal_base(Pos,X,Y) & goal_base(Pos,X,Y+1)<-
	-+goal_base(c,X,Y+1).

