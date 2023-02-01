// Agent bob in project MAPC2018.mas2j
{ include("strategy/identification.asl", identification) }
{ include("strategy/exploration.asl", exploration) }
{ include("strategy/task.asl", task) }
/* Initial beliefs and rules */       
location(self,_,0,0).
agent_mode(exploration).


/* Initial goals */            
                           
!start.                

/* Plans */

+!start : true <- 
	.print("hello massim world.").
// agent explore the world
+actionID(X) : agent_mode(exploration) <- 
	.random(RandomNumber);
	!explore(RandomNumber).

// agent finds goal position
+actionID(ID) : location(goal_n,_,X,Y) & agent_mode(find_goal) <- 
	.print("going to the goal postition nnnnnnnnnnn:",X,",",Y);
	!move_on(X,Y).
+actionID(ID) : location(goal_c,_,X,Y) & agent_mode(find_goal) <- 
	.print("going to the goal postition ccccccccccc:",X,",",Y);
	!move_on(X,Y).
// the agent fetches a block
+actionID(ID) : agent_mode(find_blocks) <- 
	.print("going to the goal postition ccccccccccc:",X,",",Y);
	!find_blocks(b0).

// the agent finds a block given a block type
+!find_blocks(Btype) : block(Dir,Btype) <-
	true.
+!find_blocks(Btype) : block(Dir,Details) & not (Btype == Details)<-
	!find_dispensers(Btype);
	//!check_direction().
	!request_block(Btype);
	!attach_block(Btype).
	
	
+!find_dispensers(Dtype) : location(dispenser,Dtype,X,Y) <-
	!move_to(X,Y).
// currently the agent doesn't know where the dispenser is, explore to find it
+!find_dispensers(Dtype) : not location(dispenser,Dtype,X,Y) <-
	.random(RandomNumber); 
	!explore(RandomNumber).

+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == -1) & (Y-YY == 0) & not location(block,Btype,X,Y)<-
	request(w).
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == 1) & (Y-YY == 0) & not location(block,Btype,X,Y)<-
	request(e).
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == 0) & (Y-YY == -1) & not location(block,Btype,X,Y)<-
	request(s).
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == 0) & (Y-YY == 1) & not location(block,Btype,X,Y)<-
	request(n).
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == -1) & (Y-YY == 0) & location(block,Btype,X,Y)<-
	true.
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == 1) & (Y-YY == 0) & location(block,Btype,X,Y)<-
	true.
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == 0) & (Y-YY == -1) & location(block,Btype,X,Y)<-
	true.
+!request_block(Btype) : location(dispenser,Btype,X,Y) & location(self,_,XX,YY) & (X-XX == 0) & (Y-YY == 1) & location(block,Btype,X,Y)<-
	true.

+!attach_block(Btype) : location(self,_,XX,YY) & location(block,Btype,X,Y) & (X-XX == -1) & (Y-YY == 0)<-
	attach(w).
+!attach_block(Btype) : location(self,_,XX,YY) & location(block,Btype,X,Y) & (X-XX == 1) & (Y-YY == 0)<-
	attach(e).
+!attach_block(Btype) : location(self,_,XX,YY) & location(block,Btype,X,Y) & (X-XX == 0) & (Y-YY == -1)<-
	attach(s).
+!attach_block(Btype) : location(self,_,XX,YY) & location(block,Btype,X,Y) & (X-XX == 0) & (Y-YY == 1)<-
	attach(n).
	
+!explore(RandomNumber): true<-
	!move(RandomNumber);
	.print("agent explore the world").

+!move(RandomNumber): (RandomNumber<0.25) <-
	-+location(self,_,X,Y+1);
	move(n);
	.print("agent move north").
+!move(RandomNumber): (RandomNumber>=0.25 & RandomNumber<0.5) & location(self,_,X,Y) <-
	-+location(self,_,X+1,Y);       
	move(e);
	.print("agent move east").
+!move(RandomNumber): (RandomNumber>=0.5 & RandomNumber<0.75) & location(self,_,X,Y)<-
	-+location(self,_,X,Y-1);        
	move(s);
	.print("agent move south").
+!move(RandomNumber): (RandomNumber>=0.75 & RandomNumber<1) & location(self,_,X,Y)<-
	-+location(self,_,X-1,Y); 
	move(w);
	.print("agent move west").

	

+!move_to(X,Y): location(self,_,XX,YY) & (X-XX < -1)<-
	-+location(self,_,XX-1,YY); 
	move(w).
+!move_to(X,Y): location(self,_,XX,YY) & (X-XX > 1)<-
	-+location(self,_,XX+1,YY);   
	move(e).
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY < 0) & ((X-XX == 1) | (X-XX == -1)) <-
	-+location(self,_,XX,YY+1);
	move(n).
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY > 0) & ((X-XX == 1) | (X-XX == -1)) <-
	-+location(self,_,XX,YY+1);
	move(s).
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY < -1)<-
	-+location(self,_,XX,YY+1);
	move(s).
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY > 1)<-
	-+location(self,_,XX,YY+1);
	move(n).
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY < 0) & ((X-XX == 1) | (X-XX == -1)) <-
	-+location(self,_,XX,YY+1);
	move(n).
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY > 0) & ((X-XX == 1) | (X-XX == -1)) <-
	-+location(self,_,XX,YY+1);
	move(s).

// the agent must stop once it find the location
+!move_to(X,Y): location(self,_,XX,YY) & (Y-YY == 0) & ((X-XX == 1) | (X-XX == -1)) <-
	true.
+!move_to(X,Y): location(self,_,XX,YY) & (X-XX == 0) & ((Y-YY == 1) | (Y-YY == -1)) <-
	true.

+!move_on(X,Y): location(self,_,XX,YY) & (X-XX < 0)<-
	-+location(self,se,YY); 
	move(w).
+!move_on(X,Y): location(self,_,XX,YY) & (X-XX > 0)<-
	-+location(self,_,XX+1,YY);  
	move(e).
+!move_on(X,Y): location(self,_,XX,YY) & (X-XX == 0) & (Y-YY > 0)<-
	-+location(self,_,XX,YY+1);
	move(n).
+!move_on(X,Y): location(self,_,XX,YY) & (X-XX == 0) & (Y-YY < 0)<-
	-+location(self,_,XX,YY+1);
	move(s).
+!move_on(X,Y): location(self,_,XX,YY) & (X-XX == 0) & (Y-YY == 0)<-
	-agent_mode(find_goal).

// see a thing
+thing(X, Y, Type, Details) : location(self,_,XX,YY)<-
	+location(Type,Details,XX+X,YY+Y);
	.print("the agent sees a ",Type,",",Details).


// attach a block
+thing(X, Y, Type, Details) : (Type == block) & (X == 1) & (Y == 0) & agent_mode(find_blocks) <- 
	attach(e);
	-+agent_mode(find_goal);
	+block(e,Details);
	.print("attach a block").
+thing(X, Y, Type, Details) : (Type == block) & (X == -1) & (Y == 0) & agent_mode(find_blocks) <- 
	attach(w);
	-+agent_mode(find_goal);
	+block(w,Details);
	-thing(X, Y, Type, Details);
	.print("attach a block").
+thing(X, Y, Type, Details) : (Type == block) & (X == 0) & (Y == 1) & agent_mode(find_blocks) <- 
	attach(n);
	-+agent_mode(find_goal);
	+block(n,Details);
	.print("attach a block").          
+thing(X, Y, Type, Details) : (Type == block) & (X == 0) & (Y == -1) & agent_mode(find_blocks) <- 
	attach(s);
	-+agent_mode(find_goal);
	+block(s,Details);
	.print("attach a block").

+attached(Y): true <-
	-+agent_mode(exploration).

// agent see a goal
+goal(X,Y): holding_block(Dir,Details)<-  
	-+exploration_mode(off);
	+location(goal_n,_,XX+X,YY+Y).

+location(Thing,_,X,Y): location(goal_n,_,X,Y) & location(goal_n,_,X-1,Y)<-
	+location(goal_c,X-1,Y).
+location(Thing,_,X,Y): location(goal_n,_,X,Y) & location(goal_n,_,X+1,Y)<-
	+location(goal_c,X+1,Y).
+location(Thing,_,X,Y): location(goal_n,_,X,Y) & location(goal_n,_,X,Y-1)<-
	+location(goal_c,X,Y-1).
+location(Thing,_,X,Y): location(goal_n,_,X,Y) & location(goal_n,_,X,Y+1)<-
	+location(goal_c,X,Y+1).

+task(N, D, R, Req) : (.length(Req) == 1) <-
	//-+agent_mode(find_blocks);
	-+current_task(N, D, R, Req);
	.member(V,Req);
	//.length(V,Len);
	.type(V,T);
	.print("the agent receives a task=",T);
	.
