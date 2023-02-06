// Agent bob in project MAPC2018.mas2j
{ include("strategy/identification.asl", identification) }
{ include("strategy/exploration.asl", exploration) }
{ include("strategy/task.asl", task) }
/* Initial beliefs and rules */       
location(self,MyN,0,0).
agent_mode(exploration).

ava_dir(e).
ava_dir(s).
ava_dir(w).
ava_dir(n).

get_dir(0,-1,Dir) :- Dir = n.
get_dir(0,1,Dir) :- Dir = s.
get_dir(1,0,Dir) :- Dir = e.
get_dir(-1,0,Dir) :- Dir = w.
get_dir(X,Y,null) :- X > 1 & X < -1 & Y > 1 & Y < -1.

check_dir(X,Y,w) :- X < -1.
check_dir(X,Y,e) :- X > 1.
check_dir(-1,Y,n) :- Y < 0.
check_dir(-1,Y,s) :- Y > 0.
check_dir(1,Y,s) :- Y > 0.
check_dir(1,Y,n) :- Y < 0.
check_dir(0,Y,n) :- Y < -1.
check_dir(0,Y,s) :- Y > 1.
check_dir(0,1,Dir) :- Dir = null.
check_dir(0,-1,Dir) :- Dir = null.
check_dir(1,0,Dir) :- Dir = null.
check_dir(-1,0,Dir) :- Dir = null.

check_dir_on(X,_,e) :- X < 0.
check_dir_on(X,_,w) :- X > 0.
check_dir_on(0,Y,s) :- Y < 0.
check_dir_on(0,Y,n) :- Y > 0.
check_dir_on(0,0,Dir) :- Dir = null.

rotate_dir(n,e,RDir) :- RDir = ccw.
rotate_dir(n,s,RDir) :- RDir = ccw.
rotate_dir(n,w,RDir) :- RDir = cw.
rotate_dir(e,s,RDir) :- RDir = ccw.
rotate_dir(e,w,RDir) :- RDir = ccw.
rotate_dir(e,n,RDir) :- RDir = cw.
rotate_dir(s,w,RDir) :- RDir = ccw.
rotate_dir(s,n,RDir) :- RDir = ccw.
rotate_dir(s,e,RDir) :- RDir = cw.
rotate_dir(w,n,RDir) :- RDir = ccw.
rotate_dir(w,e,RDir) :- RDir = ccw.
rotate_dir(w,s,RDir) :- RDir = cw.

get_req_type(Req,X,Y,Btype) :- .member(req(X,Y,Btype),Req).

count_location(B,N) :- .count(location(B,_,X,Y),N).

count_block(Btype,N) :- .count(block(_,Btype),N).

test_block(Btype,X,Y,N) :- .count(location(block,Btype,X,Y),N).

count_task_base(Name,N) :- .count(task_base(Name,_,_,_),N).


/* Initial goals */

!start.                

/* Plans */

+!start : true <- 
	.print("hello massim world.").
+step(S): true <-
	true;
	.
// agent explore the world
+actionID(X) : agent_mode(exploration) <- 
	.print("current mode exploration");
	.random(RandomNumber);
	!explore(RandomNumber).

// agent finds goal position
+actionID(ID) : location(goal,_,GoalX,GoalY) & agent_mode(find_goal) & current_task(N, D, R,TX,TY, Req) <- 
	.print("current mode find_goal");
	!move_on(GoalX,GoalY);
	.
// the agent fetches a block
+actionID(ID) : stock(Btype,X,Y) &  agent_mode(find_blocks) <- 
	//.print("stock abs ================",X,",",Y);
	//.print("stock rel ================",X2,",",Y2);
	.print("current mode find_blocks");
	!find_blocks(Btype,X,Y).

+actionID(ID) : agent_mode(submit_task) & current_task(N, D, R,TX,TY, Req) <- 
	submit(N);
	-current_task(N, D, R,TX,TY, Req);
	.

+!explore(RandomNumber): true<-
	!move(RandomNumber);
	.print("agent explore the world").

+!move(RandomNumber): (RandomNumber<0.25) <-
	-location(self,_,X,Y); 
	+location(self,1,X,(Y-1));
	move(n);
	.print("agent move north").
+!move(RandomNumber): (RandomNumber>=0.25 & RandomNumber<0.5) <-
	-location(self,_,X,Y); 
	+location(self,2,(X+1),Y);
	move(e);
	.print("agent move east").
+!move(RandomNumber): (RandomNumber>=0.5 & RandomNumber<0.75) <-
	-location(self,_,X,Y); 
	+location(self,3,X,(Y+1));       
	move(s);
	.print("agent move south").
+!move(RandomNumber): (RandomNumber>=0.75 & RandomNumber<1) <-
	-location(self,_,X,Y); 
	+location(self,4,(X-1),Y);
	move(w);
	.print("agent move west").

// the agent finds a block given a block type
+!find_blocks(Btype,X,Y) : true <-
	!find_dispensers(Btype,X,Y);
	.

+!check_direction(X,Y,Btype) : check_dir(X,Y,Dir1) & ava_dir(Dir1) & location(self,MyN,MyX,MyY)<-
	//.print("the agent check_direction Dir1=:",Dir1,",MyX=",MyX,",MyY=",MyY);
	//.print("the agent check_direction Dir1:",Dir1,",X=",X,",Y=",Y);
	//.print("the agent check_direction Dir1=:",Dir1,",",(X-MyX),",",(Y-MyY));
	!request_block(X,Y,Btype);
	.
+!check_direction(X,Y,Btype) : check_dir(X,Y,Dir1) & ava_dir(Dir2) & rotate_dir(Dir1,Dir2,RDir) <-
	rotate(RDir);
	.

	
+!rotate_direction(X,Y) : get_dir(X,Y,Dir1) & block(Dir2,Details) & rotate_dir(Dir1,Dir2,RDir) <-
	if (Dir1 == Dir2){
		-+agent_mode(submit_task);
	}else{
		rotate(RDir)
	};
	.
+!find_dispensers(Dtype,X,Y) : true<-
	!move_to(X,Y,Dtype);
	.

+!request_block(X,Y,Btype) : location(self,MyN,MyX,MyY) & get_dir((X-MyX),(Y-MyY),Dir) & test_block(Btype,(X),(Y),N) <-
	//.print("the agent request_block X-MyX:",(X-MyX),",Y-MyY=",(Y-MyY),",N=",N,",Dir=",Dir);
	if(N > 0){
		!attach_block(Btype);
	}else{
		request(Dir);
	};
	.


+!attach_block(Btype) : location(self,MyN,MyX,MyY) & location(block,Btype,X,Y) & get_dir((X-MyX),(Y-MyY),Dir)<-
	.print("agent finished find_blocks");
	attach(Dir);
	-ava_dir(Dir);
	-stock(_,_,_);
	-+agent_mode(exploration);
	.

+!move_to(X,Y,Btype): location(self,MyN,MyX,MyY) & check_dir((X-MyX),(Y-MyY),Dir)<-
	if(Dir == null){
		!check_direction(X,Y,Btype);
	}else{
		-location(self,MyN,MyX,MyY); 
		if(Dir == n){
			+location(self,5,MyX,MyY-1);
		}elif(Dir == e){
			+location(self,6,MyX+1,MyY);
		}elif(Dir == s){
			+location(self,7,MyX,MyY+1);
		}elif(Dir == w){
			+location(self,8,(MyX-1),MyY);
		};
		move(Dir);
		//.print("the agent move to the dispenser Dir=:",Dir,",MyX=",MyX,",MyY=",MyY);
		//.print("the agent move to the dispenser Dir:",Dir,",X=",X,",Y=",Y);
		//.print("the agent move to the dispenser:",Dir,",",(X-MyX),",",(Y-MyY));
	};
	.

+!move_on(X,Y): location(self,MyN,MyX,MyY) & check_dir_on(X-MyX,Y-MyY,Dir) & task_base(N, D, R,TX,TY, B)<-
	-location(self,MyN,MyX,MyY);
	.print("the agent move to the (X-MyX):",(X-MyX),",(Y-MyY)=",(Y-MyY),",Dir=",Dir);
	if (Dir == null){
		!rotate_direction(TX,TY);
	}else{
		if (Dir == n){
			+location(self,9,MyX,MyY+1);
		}elif(Dir == e){
			+location(self,10,MyX-1,MyY);
		}elif(Dir == s){
			+location(self,11,MyX,(MyY-1));
		}elif(Dir == w){
			+location(self,12,MyX+1,MyY);
		};
		move(Dir);
	};
	.

+!stock(Btype,X,Y) : count_block(Btype,N) <-
	if(N == 0){
		+stock(Btype,X,Y);
		-+agent_mode(find_blocks);
	}
	.

+thing(X, Y, Type, Details) : location(self,MyN,MyX,MyY) & location(Type,Details,ThingX,ThingY) <-
	if(not (ThingX == (MyX+X)) & not (ThingY == (MyY+Y)) & Details == Dtype){
		+location(Type,Details,(MyX+X),(MyY+Y));
		.print("the agent sees a ",Type,",",Details);
	};
	.

+thing(X, Y, Type, Details) : location(self,MyN,MyX,MyY) & count_location(Type,N) & (N == 0) <-
	+location(Type,Details,(MyX+X),(MyY+Y));
	if(Type == dispenser){
		!stock(Details,(MyX+X),(MyY+Y));
	};
	.print("the agent sees a ",Type,",Details=",Details,",(MyX+X)=",(MyX+X),",(MyY+Y)=",(MyY+Y));
	.

// agent see a goal

+goal(X,Y): location(self,MyN,MyX,MyY)  & count_location(goal,N) & (N == 0) & task_base(N, D, R,TX,TY, Btype) & count_block(Btype,BN)<- 
	+location(goal,_,(MyX+X),(MyY+Y));
	.print("the agent sees a goal:",(MyX+X),",",(MyY+Y));
	if(BN > 0){
		-+current_task(N, D, R,TX,TY, Btype);
		-+agent_mode(find_goal);
		.print("----------------------------start task");
	};
	.
+goal(X,Y): location(self,MyN,MyX,MyY) & location(goal,_,GoalX,GoalY) & task_base(N, D, R,TX,TY, Btype) & count_block(Btype,BN)<- 
	if( not (GoalX == (MyX+X)) & not (GoalY == (MyY+Y))){
		+location(goal,_,(MyX+X),(MyY+Y));
		.print("the agent sees a goal:",(MyX+X),",",(MyY+Y));
		if(BN > 0){
			-+current_task(N, D, R,TX,TY, Btype);
			-+agent_mode(find_goal);
			.print("----------------------------start task");
		};
	};
	.
+block(Dir,Btype) : location(goal,_,GoalX,GoalY) & task_base(N, D, R,TX,TY, Btype) & block(Dir,Btype) <-
	-+current_task(N, D, R,TX,TY, Btype);
	-+agent_mode(find_goal);
	.print("----------------------------start task");
	.
+task_base(N, D, R,TX,TY, Btype) : location(goal,_,GoalX,GoalY) & block(Dir,Btype) <-
	-+current_task(N, D, R,TX,TY, Btype);
	-+agent_mode(find_goal);
	.print("----------------------------start task");
	.
// agent see a obstacle
//+obstacle(X,Y): location(self,MyN,MyX,MyY) & count_location(obstacle,N) & (N == 0) <- 
//	+location(obstacle,_,(MyX+X),(MyY+Y));
//	.print("the agent sees an obstacle :",(MyX+X),",",(MyY+Y));
//	.
//+obstacle(X,Y): location(self,MyN,MyX,MyY) & location(obstacle,_,ObsX,ObsY) <- 
//	if(not (ObsX == (MyX+X)) & not (ObsY == (MyY+Y))){
//		+location(obstacle,_,(MyX+X),(MyY+Y));
//		.print("the agent sees an obstacle :");
//	};
//	.

+task(N, D, R, Req) : (.length(Req) == 1) & count_task_base(N,Num) & location(self,MyN,MyX,MyY)<- 
	if(Num == 0){
		.member(req(X,Y,B),Req);
		.print("the agent receive a new task ",N,",D=", D,",R=", R,",B=", B,",X=", X,",Y=",Y);
		+task_base(N, D, R,TX,TY,B);
	};
	.

+lastAction(move) : lastActionResult(failed_path) & lastActionParams(Params) & location(self,MyN,MyX,MyY)<-
	.member(V,Params);
	-location(self,MyN,MyX,MyY);
	if(V == n){
		+location(self,MyN,MyX,MyY+1);
	}elif(V == e){
		+location(self,MyN,MyX,MyY-1);
	}elif(V == s){
		+location(self,MyN,MyX,MyY-1);
	}elif(V == w){
		+location(self,MyN,MyX,MyY+1);
	};
	//.print("------------lastaction failed:",V)
	.

	
+location(self,N,X,Y) : true <-
	true;
	//.print("X inspect :",N,",",X)
	.
