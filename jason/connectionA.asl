// Agent bob in project MAPC2018.mas2j
{ include("strategy/identification.asl", identification) }
{ include("strategy/exploration.asl", exploration) }
{ include("strategy/task.asl", task) }
/* Initial beliefs and rules */
agent_location(0,0,0).
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

get_dir_on(0,-1,Dir) :- Dir = s.
get_dir_on(0,1,Dir) :- Dir = n.
get_dir_on(1,0,Dir) :- Dir = w.
get_dir_on(-1,0,Dir) :- Dir = e.
get_dir_on(X,Y,null) :- X > 1 & X < -1 & Y > 1 & Y < -1.

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

check_dir_on(X,Y,w) :- X < 0.
check_dir_on(X,Y,e) :- X > 0.
check_dir_on(0,Y,n) :- Y < 0.
check_dir_on(0,Y,s) :- Y > 0.
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
rotate_dir(n,n,RDir) :- RDir = null.
rotate_dir(e,e,RDir) :- RDir = null.
rotate_dir(s,s,RDir) :- RDir = null.
rotate_dir(w,w,RDir) :- RDir = null.

get_req_type(Req,X,Y,Btype) :- .member(req(X,Y,Btype),Req).

count_location(B,N) :- .count(location(B,_,X,Y),N).

count_block(Btype,N) :- .count(block(_,Btype),N).

test_block(Btype,X,Y,N) :- .count(location(block,Btype,X,Y),N).

count_task_base(N,TN) :- .count(task_base(N, _, _,_),TN).

random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

update_dir(w,cw,Dir2) :- Dir2 = n.
update_dir(n,cw,Dir2) :- Dir2 = e.
update_dir(e,cw,Dir2) :- Dir2 = s.
update_dir(s,cw,Dir2) :- Dir2 = w.
update_dir(w,ccw,Dir2) :- Dir2 = s.
update_dir(n,ccw,Dir2) :- Dir2 = w.
update_dir(e,ccw,Dir2) :- Dir2 = n.
update_dir(s,ccw,Dir2) :- Dir2 = e.
/* Initial goals */

!start.                

/* Plans */

+!start : true <- 
	.my_name(N);
	+agent_name(N);
	.print("agent name is ",N);
	.print("hello massim world.");
	.
	
+step: true <-
	print(" find the task and the block---------------------");
	.
// agent explore the world
+actionID(X) : agent_mode(exploration) <- 
	.print("current mode exploration");
	!explore.

// agent explore the world
//+actionID(X) : agent_mode(exploration) & location(dispenser,Btype,X,Y) <- 
//	.print("change current mode from exploration to find_blocks");
//	!stock(Btype,X,Y);
//	!find_blocks(Btype,X,Y);
//	.

// agent finds goal position
+actionID(ID) : location(goal,task,GoalX,GoalY) & agent_mode(find_goal) & current_task(N, D, R,TX,TY, Req) <- 
	.print("current mode find_goal");
	!move_on(GoalX,GoalY);
	.
// the agent fetches a block
+actionID(ID) : stock(Btype,X,Y) &  agent_mode(find_blocks) <- 
	//.print("stock abs ================",X,",",Y);
	//.print("stock rel ================",X2,",",Y2);
	.print("current mode find_blocks");
	!find_blocks(Btype,X,Y);
	.


+!explore: true <-
	!move_random;
	.print("agent explore the world");
	.

@plan[atomic]
+!move_random : .random(RandomNumber) & random_dir([n,s,e,w],RandomNumber,Dir) & agent_location(MyN,MyX,MyY)<-
	if(Dir == n){
		-+agent_location(1,MyX,(MyY-1));
	}elif(Dir == e){
		-+agent_location(2,(MyX+1),MyY);
	}elif(Dir == s){
		-+agent_location(3,MyX,(MyY+1)); 
	}elif(Dir == w){
		-+agent_location(4,(MyX-1),MyY);
	};
	move(Dir);
	.print("agent move random:",Dir);
	.

// the agent finds a block given a block type
+!find_blocks(Btype,X,Y) : true <-
	!find_dispensers(Btype,X,Y);
	.

+!check_direction(X,Y,Btype) : check_dir(X,Y,Dir1) & ava_dir(Dir1) & agent_location(MyN,MyX,MyY)<-
	//.print("the agent check_direction Dir1=:",Dir1,",MyX=",MyX,",MyY=",MyY);
	//.print("the agent check_direction Dir1:",Dir1,",X=",X,",Y=",Y);
	//.print("the agent check_direction Dir1=:",Dir1,",",(X-MyX),",",(Y-MyY));
	!request_block(X,Y,Btype);
	.
+!check_direction(X,Y,Btype) : check_dir(X,Y,Dir1) & ava_dir(Dir2) & rotate_dir(Dir1,Dir2,RDir) <-
	rotate(RDir);
	!update_block_dir(RDir);
	!update_ava_dir(RDir);
	.print("agent rotate Dir1=",Dir1,",Dir2=",Dir2,",RDir=",RDir,",X=",X,",Y=",Y);
	.

	
+!rotate_direction(X,Y) : get_dir_on(X,Y,Dir1) & block(Dir2,Details) & rotate_dir(Dir1,Dir2,RDir) & current_task(N, D, R,TX,TY, B) & location(goal,task,GoalX,GoalY)<-
	if (RDir == null){
		submit(N);
		.print("agent submit the task=",N);
		-location(goal,task,GoalX,GoalY);
		+location(goal,_,GoalX,GoalY);
		-current_task(N, D, R,TX,TY, B);
		-task_base(N, D, R,TX,TY, B);
		-block(Dir2,Details);
		+ava_dir(Dir1);
		-+agent_mode(exploration);
	}else{
		rotate(RDir);
		!update_block_dir(RDir);
		!update_ava_dir(RDir);
		.print("agent rotate Dir1=",Dir1,",Dir2=",Dir2,",RDir=",RDir,",X=",X,",Y=",Y);
	};
	.
	
+!update_block_dir(RDir) : block(Dir1,Detail) & update_dir(Dir1,RDir,Dir2)<-
	-block(Dir1,Detail);
	+block(Dir2,Detail);
	.
+!update_ava_dir(RDir): ava_dir(Dir1) & update_dir(Dir1,RDir,Dir2)<-
	-ava_dir(Dir1,Detail);
	+ava_dir(Dir2,Detail);
	.
	
+!find_dispensers(Dtype,X,Y) : true<-
	!move_to(X,Y,Dtype);
	.

+!request_block(X,Y,Btype) : agent_location(MyN,MyX,MyY) & get_dir((X-MyX),(Y-MyY),Dir) & test_block(Btype,(X),(Y),N) <-
	//.print("the agent request_block X-MyX:",(X-MyX),",Y-MyY=",(Y-MyY),",N=",N,",Dir=",Dir);
	if(N > 0){
		!attach_block(Btype);
	}else{
		request(Dir);
		.print("agent request block:",Dir);
	};
	.


+!attach_block(Btype) : agent_location(MyN,MyX,MyY) & location(block,Btype,X,Y) & get_dir((X-MyX),(Y-MyY),Dir)<-
	.print("agent finished find_blocks");
	attach(Dir);
	-ava_dir(Dir);
	-stock(_,_,_);
	-location(block,Btype,X,Y);
	+block(Dir,Btype);
	-+agent_mode(exploration);
	.

+!move_to(X,Y,Btype): agent_location(MyN,MyX,MyY) & check_dir((X-MyX),(Y-MyY),Dir)<-
	if(Dir == null){
		!check_direction(X,Y,Btype);
	}else{
		if(Dir == n){
			-+agent_location(5,MyX,MyY-1);
		}elif(Dir == e){
			-+agent_location(6,MyX+1,MyY);
		}elif(Dir == s){
			-+agent_location(7,MyX,MyY+1);
		}elif(Dir == w){
			-+agent_location(8,(MyX-1),MyY);
		};
		move(Dir);
		//.print("the agent move to the dispenser Dir=:",Dir,",MyX=",MyX,",MyY=",MyY);
		//.print("the agent move to the dispenser Dir:",Dir,",X=",X,",Y=",Y);
		//.print("the agent move to the dispenser:",Dir,",",(X-MyX),",",(Y-MyY));
	};
	.

+!move_on(X,Y): agent_location(MyN,MyX,MyY) & check_dir_on(X-MyX,Y-MyY,Dir) & current_task(N, D, R,TX,TY, B)<-
	.print("the agent move to the X:",X,",X=",Y);
	.print("the agent move to the MyX:",MyX,",MyY=",MyY);
	.print("the agent move to the (X-MyX):",(X-MyX),",(Y-MyY)=",(Y-MyY),",Dir=",Dir);
	if (Dir == null){
		!rotate_direction(TX,TY);
	}else{
		if(Dir == n){
			-+agent_location(5,MyX,MyY-1);
		}elif(Dir == e){
			-+agent_location(6,MyX+1,MyY);
		}elif(Dir == s){
			-+agent_location(7,MyX,MyY+1);
		}elif(Dir == w){
			-+agent_location(8,(MyX-1),MyY);
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

+thing(X, Y, Type, Details) : agent_location(MyN,MyX,MyY) & location(Type,Details,ThingX,ThingY) <-
	if(not (ThingX == (MyX+X)) & not (ThingY == (MyY+Y)) & Details == Dtype){
		+location(Type,Details,(MyX+X),(MyY+Y));
		.print("the agent sees a ",Type,",",Details);
	};
	.

+thing(X, Y, Type, Details) : agent_location(MyN,MyX,MyY) & count_location(Type,N) & (N == 0) <-
	+location(Type,Details,(MyX+X),(MyY+Y));
	if(Type == dispenser){
		!stock(Details,(MyX+X),(MyY+Y));
	};
	.print("the agent sees a ",Type,",Details=",Details,",(MyX+X)=",(MyX+X),",(MyY+Y)=",(MyY+Y));
	.

// agent see a goal
//+goal(X,Y): agent_location(MyN,MyX,MyY)  & count_location(goal,N) & (N == 0)<- 
//	+location(goal,_,(MyX+X),(MyY+Y));
//	.print("the agent sees a goal:",(MyX+X),",",(MyY+Y));
//	.
+goal(X,Y): agent_location(MyN,MyX,MyY)  & not location(goal,_,_,_) & task_base(N, D, R,TX,TY, Btype) & block(Bdir,Btype)<- 
	+location(goal,task,(MyX+X),(MyY+Y));
	.print("the agent sees a goal:",(MyX+X),",",(MyY+Y));
	-+current_task(N, D, R,TX,TY, Btype);
	-+agent_mode(find_goal);
	.print("agent start task");
	.
+goal(X,Y): agent_location(MyN,MyX,MyY) & location(goal,_,GoalX,GoalY) & task_base(N, D, R,TX,TY, Btype) & block(Bdir,Btype) & not current_task(N, D, R,TX,TY, Btype)<- 
	if( not (GoalX == (MyX+X)) & not (GoalY == (MyY+Y))){
		+location(goal,task,(MyX+X),(MyY+Y));
		.print("the agent sees a goal:",(MyX+X),",",(MyY+Y));
		+current_task(N, D, R,TX,TY, Btype);
		-+agent_mode(find_goal);
		.print("agent start task");
	};
	.
+block(Dir,Btype) : location(goal,_,GoalX,GoalY) & task_base(N, D, R,TX,TY, Btype) & location(goal,_,GoalX,GoalY) & not current_task(N, D, R,TX,TY, Btype)<-
	-location(goal,_,GoalX,GoalY);
	+location(goal,task,GoalX,GoalY);
	+current_task(N, D, R,TX,TY, Btype);
	-+agent_mode(find_goal);
	.print("agent start task");
	.
+task_base(N, D, R,TX,TY, Btype) : location(goal,_,GoalX,GoalY) & block(Dir,Btype) & not current_task(N, D, R,TX,TY, Btype)<-
	-location(goal,_,GoalX,GoalY);
	+location(goal,task,GoalX,GoalY);
	+current_task(N, D, R,TX,TY, Btype);
	-+agent_mode(find_goal);
	.print("agent start task");
	.
// agent see a obstacle
//+obstacle(X,Y): agent_location(MyN,MyX,MyY) & count_location(obstacle,N) & (N == 0) <- 
//	+location(obstacle,_,(MyX+X),(MyY+Y));
//	.print("the agent sees an obstacle :",(MyX+X),",",(MyY+Y));
//	.
//+obstacle(X,Y): agent_location(MyN,MyX,MyY) & location(obstacle,_,ObsX,ObsY) <- 
//	if(not (ObsX == (MyX+X)) & not (ObsY == (MyY+Y))){
//		+location(obstacle,_,(MyX+X),(MyY+Y));
//		.print("the agent sees an obstacle :");
//	};
//	.


+task(N, D, R, Req) : (.length(Req) == 1) & not task_base(N, D, R,_,_,_)<- 
	.member(req(X,Y,B),Req);
	.print("the agent receive a new task ",N,",D=", D,",R=", R,",B=", B,",X=", X,",Y=",Y);
	+task_base(N, D, R,TX,TY,B);
	.

+lastAction(move) : lastActionResult(failed_path) & lastActionParams(Params) & agent_location(MyN,MyX,MyY)<-
	.member(V,Params);
	if(V == n){
		-+agent_location(MyN,MyX,MyY+1);
	}elif(V == e){
		-+agent_location(MyN,MyX-1,MyY);
	}elif(V == s){
		-+agent_location(MyN,MyX,MyY-1);
	}elif(V == w){
		-+agent_location(MyN,MyX,MyY+1);
	};
	//.print("------------lastaction failed:",V)
	.

	
+agent_location(N,X,Y) : true <-
	.print("add self location inspect :",N,",",X,",",Y);
	//true;
	.
