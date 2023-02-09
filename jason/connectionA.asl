// Agent bob in project MAPC2018.mas2j
/* Initial beliefs and rules */
agent_location(0,0,0).
agent_mode(exploration).
dispenser_queue([500]).
goal_queue([500]).


ava_dir(e).
ava_dir(s).
ava_dir(w).
ava_dir(n).
get_ava_dir(Dir) :- (ava_dir(e) & Dir = e)|(ava_dir(s) & Dir = s)|(ava_dir(w) & Dir = w)|(ava_dir(n) & Dir = n).

get_dir(0,-1,Dir) :- Dir = n.
get_dir(0,1,Dir) :- Dir = s.
get_dir(1,0,Dir) :- Dir = e.
get_dir(-1,0,Dir) :- Dir = w.
get_dir(X,Y,e) :- (X > 1 | X < -1) & (Y > 1 | Y < -1).

get_dir_on(0,-1,Dir) :- Dir = s.
get_dir_on(0,1,Dir) :- Dir = n.
get_dir_on(1,0,Dir) :- Dir = w.
get_dir_on(-1,0,Dir) :- Dir = e.
get_dir_on(X,Y,null) :- (X > 1 | X < -1) & (Y > 1 | Y < -1).

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

count_location(B,N) :- .count(location(B,_,_,_),N).

count_block(Btype,N) :- .count(block(_,Btype),N).
count_block_all(N) :- .count(block(_,_),N).

test_block(Btype,X,Y,N) :- .count(location(block,Btype,X,Y),N).

random_dir(DirList,RandomNumber,Dir) :- (RandomNumber <= 0.25 & .nth(0,DirList,Dir)) | (RandomNumber <= 0.5 & .nth(1,DirList,Dir)) | (RandomNumber <= 0.75 & .nth(2,DirList,Dir)) | (.nth(3,DirList,Dir)).

update_dir(w,cw,Dir2) :- Dir2 = n.
update_dir(n,cw,Dir2) :- Dir2 = e.
update_dir(e,cw,Dir2) :- Dir2 = s.
update_dir(s,cw,Dir2) :- Dir2 = w.
update_dir(w,ccw,Dir2) :- Dir2 = s.
update_dir(n,ccw,Dir2) :- Dir2 = w.
update_dir(e,ccw,Dir2) :- Dir2 = n.
update_dir(s,ccw,Dir2) :- Dir2 = e.

get_random_pointX(RandomNumber,X) :- (RandomNumber <= 0.16 & X = 0) | (RandomNumber <= 0.32 & X = 1) | (RandomNumber <= 0.48 & X=2) | (RandomNumber <= 0.64 & X=3) | (RandomNumber <= 0.80 & X=4) | (RandomNumber <= 1 & X=5).
get_random_pointY(R1,R2,X1,X,Y) :- (R1 <= 0.5 & R2 <= 0.5 & X = X1*-1 & Y = (5-X1)*-1) | (R1 <= 0.5 & R2 > 0.5 & X = X1 & Y = (5-X1)*-1) | (R1 > 0.5 & R2 <= 0.5 & X = X1*-1 & Y = 5-X1) |(R1 > 0.5 & R2 > 0.5 & X = X1 & Y = 5-X1).

inspect_dispenser(R1,X,Y,TX,TY) :- (RandomNumber <= 0.5 & TX = X -1 & TY = Y) | (RandomNumber <= 1 & TX = X & TY = Y-1).

get_next_dispenser(Dtype,X,Y) :-  dispenser_queue(DQ) & .min(DQ,DSeq) & location(dispenser,Dtype,X,Y).  
get_next_goal(X,Y) :-  dispenser_queue(GQ) & .min(GQ,GSeq) & location(goal,_,X,Y,_).  
/* Initial goals */

!start.                

/* Plans */

+!start : .random(R1) & get_random_pointX(R1,X) & .random(R2) & get_random_pointX(R2,Y)<- 
	.my_name(N);
	+agent_name(N);
	.all_names(L);
	+agent_list(L);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent name is ",N);
	.print("[",H,":",M,":",S,":",MS,"] ","hello massim world.");
	+random_point(X,Y);
	.
	
+step(S): task_base(N, S, R,TX,TY,B) <-
	-task_base(N, S, R,TX,TY,B);
	.

// agent explore the world
+actionID(ID) : true<- 
	!action_pipe;
	.

// agent finds goal position
+!action_pipe : get_next_goal(GoalX,GoalY) & agent_mode(find_goal) & current_task(N, D, R,TX,TY, Req) <- 
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","current mode find_goal");
	!move_on(GoalX,GoalY);	
	.

+!action_pipe : agent_mode(exploration)<- 
	!explore;
	.
+!action_pipe : agent_mode(submitted)<- 
	skip;
	.

// the agent fetches a block
+!action_pipe : stock(Btype,X,Y) &  agent_mode(find_blocks) <-
	.time(H,M,S,MS);
	//.print("[",H,":",M,":",S,":",MS,"] ","stock abs ================",X,",",Y);
	//.print("[",H,":",M,":",S,":",MS,"] ","stock rel ================",X2,",",Y2);
	.print("[",H,":",M,":",S,":",MS,"] ","current mode find_blocks");
	!find_blocks(Btype,X,Y);
	.


+!explore: true <-
	!move_random_point;
	//!move_random;
	.
@move_random_point[atomic]
+!move_random_point: random_point(RX,RY) & agent_location(MyN,MyX,MyY)  & check_dir_on(RX-MyX,RY-MyY,Dir) & .random(R1) & .random(R2) & .random(R3) & get_random_pointX(R1,X1) & get_random_pointY(R2,R3,X1,X,Y) & .count(block(_,_),N)<-
	.time(H,M,S,MS); 	
	.print("[",H,":",M,":",S,":",MS,"] ","agent move_random_point Dir=",Dir,",RX=",RX,",RY=",RY,",N=",N);
	//.print("[",H,":",M,":",S,":",MS,"] ","agent move_random_point Dir=",Dir,",MyX=",MyX,",MyY=",MyY);
	//.print("[",H,":",M,":",S,":",MS,"] ","agent move_random_point Dir=",Dir,",RX-MyX=",RX-MyX,",RY-MyY=",RY-MyY);
	if (Dir == null){
		-+random_point(X+MyX,Y+MyY);
		!move_random_point;
		//skip;
	}else{
		if(Dir == n){
			-+agent_location(9,MyX,MyY-1);
		}elif(Dir == e){
			-+agent_location(10,MyX+1,MyY);
		}elif(Dir == s){
			-+agent_location(11,MyX,MyY+1);
		}elif(Dir == w){
			-+agent_location(12,(MyX-1),MyY);
		};
		move(Dir);
	};
	.
@move_random_point2[atomic]
+!move_random_point: location(goal,_,GoalX,GoalY,_) & agent_location(MyN,MyX,MyY) & task_base(N, D, R,TX,TY,B) & block(Bdir,B) & not current_task(_,_,_,_,_,_) & not conflict_task(N)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent receive a new task ",N,",D=", D,",R=", R,",B=", B,",X=", TX,",Y=",TY);
	.broadcast(tell,conflict_task(N));
	+current_task(N, D, R,TX,TY, B);
	-+agent_mode(find_goal);
	.print("[",H,":",M,":",S,":",MS,"] ","5--------------------------- agent start task=",N);
	.
	
@plan[atomic] 
+!move_random : .random(RandomNumber) & random_dir([n,s,e,w] ,RandomNumber,Dir) & agent_location(MyN,MyX,MyY)<-
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
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent move random:",Dir);
	.

// the agent finds a block given a block type
+!find_blocks(Btype,X,Y) : true <-
	!find_dispensers(Btype,X,Y);
	.

+!check_direction(X,Y,Btype) : agent_location(MyN,MyX,MyY) & get_dir(X-MyX,Y-MyY,Dir1) & ava_dir(Dir1)<-
	.time(H,M,S,MS);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent check_direction Dir1=:",Dir1,",MyX=",MyX,",MyY=",MyY);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent check_direction Dir1:",Dir1,",X=",X,",Y=",Y);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent check_direction Dir1=:",Dir1,",",(X-MyX),",",(Y-MyY));
	!request_block(X,Y,Btype);
	.
@check_direction[atomic]
+!check_direction(X,Y,Btype) :  agent_location(MyN,MyX,MyY) & get_dir(X-MyX,Y-MyY,Dir1) & get_ava_dir(Dir2) & rotate_dir(Dir1,Dir2,RDir) & not Dir1 == Dir2 <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent rotate Dir1=",Dir1,",Dir2=",Dir2,",RDir=",RDir,",X=",X,",Y=",Y);
	!update_block_dir(RDir);
	!update_ava_dir(RDir);
	rotate(RDir);
	.


@rotate_direction1[atomic]
+!rotate_direction(N, D, R,TX,TY,B) : get_dir_on(TX,TY,TargetDir) & block(CurrentDir,B) & not (TargetDir == CurrentDir) & rotate_dir(TargetDir,CurrentDir,RDir) <-
	!update_block_dir(RDir);
	!update_ava_dir(RDir);
	rotate(RDir);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent rotate TargetDir=",TargetDir,",CurrentDir=",CurrentDir,",RDir=",RDir,",X=",TX,",Y=",TY);
	.

@rotate_direction2[atomic]
+!rotate_direction(N, D, R,TX,TY,B) : get_dir_on(TX,TY,TargetDir) & block(TargetDir,B) <-
	-current_task(_, _, _,_,_, _);
	-block(CurrentDir,B);
	+ava_dir(CurrentDir);
	-+agent_mode(submitted);
	submit(N);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent submit the task=",N,",CurrentDir=",CurrentDir);
	.

@update_block_dir1[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(e,B2) & block(s,B3) & block(w,B4)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(e,B2);
		+block(s,B2);
		-block(s,B3);
		+block(w,B3);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(w,B2);
		+block(s,B2);
		-block(s,B3);
		+block(e,B3);
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir2[atomic]
+!update_block_dir(RDir) : block(w,B4)<-
	if(RDir== cw){
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(w,B2);
		+block(s,B2);
	};
	.
@update_block_dir3[atomic]
+!update_block_dir(RDir) : block(s,B3) <-
	if(RDir== cw){
		-block(s,B3);
		+block(w,B3);
	}elif(RDir == ccw){
		-block(s,B3);
		+block(e,B3);
	};
	.
@update_block_dir4[atomic]
+!update_block_dir(RDir) : block(e,B2)<-
	if(RDir== cw){
		-block(e,B2);
		+block(s,B2);
	}elif(RDir == ccw){
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir5[atomic]
+!update_block_dir(RDir) : block(n,B1)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
	};
	.
@update_block_dir6[atomic]
+!update_block_dir(RDir) : block(e,B2) & block(w,B4)<-
	if(RDir== cw){
		-block(e,B2);
		+block(s,B2);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(w,B2);
		+block(s,B2);
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir7[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(s,B3)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(s,B3);
		+block(w,B3);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(s,B3);
		+block(e,B3);
	};
	.
@update_block_dir8[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(w,B4)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(w,B2);
		+block(s,B2);
	};
	.
@update_block_dir9[atomic]
+!update_block_dir(RDir) : block(s,B3) & block(w,B4)<-
	if(RDir== cw){
		-block(s,B3);
		+block(w,B3);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(w,B2);
		+block(s,B2);
		-block(s,B3);
		+block(e,B3);
	};
	.
@update_block_dir10[atomic]
+!update_block_dir(RDir) : block(e,B2) & block(s,B3)<-
	if(RDir== cw){
		-block(e,B2);
		+block(s,B2);
		-block(s,B3);
		+block(w,B3);
	}elif(RDir == ccw){
		-block(s,B3);
		+block(e,B3);
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir11[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(e,B2)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(e,B2);
		+block(s,B2);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir12[atomic]
+!update_block_dir(RDir) : block(e,B2) & block(s,B3) & block(w,B4)<-
	if(RDir== cw){
		-block(e,B2);
		+block(s,B2);
		-block(s,B3);
		+block(w,B3);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(w,B2);
		+block(s,B2);
		-block(s,B3);
		+block(e,B3);
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir13[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(s,B3) & block(w,B4)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(s,B3);
		+block(w,B3);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(w,B2);
		+block(s,B2);
		-block(s,B3);
		+block(e,B3);
	};
	.
@update_block_dir14[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(e,B2) & block(w,B4)<-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(e,B2);
		+block(s,B2);
		-block(w,B4);
		+block(n,B4);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(w,B2);
		+block(s,B2);
		-block(e,B4);
		+block(n,B4);
	};
	.
@update_block_dir15[atomic]
+!update_block_dir(RDir) : block(n,B1) & block(e,B2) & block(s,B3) <-
	if(RDir== cw){
		-block(n,B1);
		+block(e,B1);
		-block(e,B2);
		+block(s,B2);
		-block(s,B3);
		+block(w,B3);
	}elif(RDir == ccw){
		-block(n,B1);
		+block(w,B1);
		-block(s,B3);
		+block(e,B3);
		-block(e,B4);
		+block(n,B4);
	};
	.
	
@update_ava_dir1[atomic]
+!update_ava_dir(RDir): ava_dir(n) & ava_dir(e) & ava_dir(s)<-
	if(RDir== cw){
		-ava_dir(n);
		+ava_dir(w);
	}elif(RDir == ccw){
		-ava_dir(s);
		+ava_dir(w);
	};
	.
@update_ava_dir2[atomic]
+!update_ava_dir(RDir): ava_dir(e) & ava_dir(s) & ava_dir(w)<-
	if(RDir== cw){
		-ava_dir(e);
		+ava_dir(n);
	}elif(RDir == ccw){
		-ava_dir(w);
		+ava_dir(n);
	};
	.
@update_ava_dir3[atomic]
+!update_ava_dir(RDir): ava_dir(s) & ava_dir(w) & ava_dir(n)<-
	if(RDir== cw){
		-ava_dir(s);
		+ava_dir(e);
	}elif(RDir == ccw){
		-ava_dir(n);
		+ava_dir(e);
	};
	.
@update_ava_dir4[atomic]
+!update_ava_dir(RDir): ava_dir(w) & ava_dir(n) & ava_dir(e)<-
	if(RDir== cw){
		-ava_dir(w);
		+ava_dir(s);
	}elif(RDir == ccw){
		-ava_dir(e);
		+ava_dir(s);
	};
	.
@update_ava_dir5[atomic]
+!update_ava_dir(RDir): ava_dir(n) & ava_dir(e)<-
	if(RDir== cw){
		-ava_dir(n);
		+ava_dir(s);
	}elif(RDir == ccw){
		-ava_dir(e);
		+ava_dir(w);
	};
	.
@update_ava_dir6[atomic]
+!update_ava_dir(RDir): ava_dir(e) & ava_dir(s)<-
	if(RDir== cw){
		-ava_dir(e);
		+ava_dir(w);
	}elif(RDir == ccw){
		-ava_dir(s);
		+ava_dir(n);
	};
	.
@update_ava_dir7[atomic]
+!update_ava_dir(RDir): ava_dir(s) & ava_dir(w)<-
	if(RDir== cw){
		-ava_dir(s);
		+ava_dir(n);
	}elif(RDir == ccw){
		-ava_dir(w);
		+ava_dir(e);
	};
	.
@update_ava_dir8[atomic]
+!update_ava_dir(RDir): ava_dir(w) & ava_dir(n)<-
	if(RDir== cw){
		-ava_dir(w);
		+ava_dir(e);
	}elif(RDir == ccw){
		-ava_dir(n);
		+ava_dir(s);
	};
	.
@update_ava_dir9[atomic]
+!update_ava_dir(RDir): ava_dir(n) & ava_dir(s)<-
	-ava_dir(n);
	-ava_dir(s);
	+ava_dir(e);
	+ava_dir(w);
	.
@update_ava_dir10[atomic]
+!update_ava_dir(RDir): ava_dir(e) & ava_dir(w)<-
	-ava_dir(e);
	-ava_dir(w);
	+ava_dir(n);
	+ava_dir(s);
	.
@update_ava_dir11[atomic]
+!update_ava_dir(RDir): ava_dir(n)<-
	if(RDir== cw){
		-ava_dir(n);
		+ava_dir(e);
	}elif(RDir == ccw){
		-ava_dir(n);
		+ava_dir(w);
	};
	.
@update_ava_dir12[atomic]
+!update_ava_dir(RDir): ava_dir(e)<-
	if(RDir== cw){
		-ava_dir(e);
		+ava_dir(s);
	}elif(RDir == ccw){
		-ava_dir(e);
		+ava_dir(n);
	};
	.
@update_ava_dir13[atomic]
+!update_ava_dir(RDir): ava_dir(s)<-
	if(RDir== cw){
		-ava_dir(s);
		+ava_dir(w);
	}elif(RDir == ccw){
		-ava_dir(s);
		+ava_dir(e);
	};
	.
@update_ava_dir14[atomic]
+!update_ava_dir(RDir): ava_dir(w)<-
	if(RDir== cw){
		-ava_dir(w);
		+ava_dir(n);
	}elif(RDir == ccw){
		-ava_dir(w);
		+ava_dir(s);
	};
	.
	
+!find_dispensers(Dtype,X,Y) : true<-
	!move_to(X,Y,Dtype);
	.

@request_block[atomic]
+!request_block(X,Y,Btype) : agent_location(MyN,MyX,MyY) & get_dir((X-MyX),(Y-MyY),Dir) & not block(Dir,Btype) & not location(block,Btype,X,Y)<-
	.time(H,M,S,MS);
	.print("[",H,":",M,":",S,":",MS,"] ","1the agent request_block X:",X,",Y=",Y,",Dir=",Dir);
	.print("[",H,":",M,":",S,":",MS,"] ","1the agent request_block MyX:",MyX,",MyY=",MyY);
	.print("[",H,":",M,":",S,":",MS,"] ","1the agent request_block X-MyX:",(X-MyX),",Y-MyY=",(Y-MyY));
	.print("[",H,":",M,":",S,":",MS,"] ","agent request block:",Dir);
	+location(block,Btype,X,Y);
	request(Dir);
	.
+!request_block(X,Y,Btype) : agent_location(MyN,MyX,MyY) & get_dir((X-MyX),(Y-MyY),Dir) & not block(Dir,Btype) & location(block,Btype,X,Y)<-
	.time(H,M,S,MS);
	.print("[",H,":",M,":",S,":",MS,"] ","2the agent request_block X:",X,",Y=",Y,",Dir=",Dir);
	.print("[",H,":",M,":",S,":",MS,"] ","2the agent request_block MyX:",MyX,",MyY=",MyY);
	.print("[",H,":",M,":",S,":",MS,"] ","2the agent request_block X-MyX:",(X-MyX),",Y-MyY=",(Y-MyY));
	!attach_block(X,Y,Btype);
	.

@attach_block[atomic] 
+!attach_block(X,Y,Btype) : agent_location(MyN,MyX,MyY) & location(block,Btype,X,Y) & get_dir((X-MyX),(Y-MyY),Dir)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent finished find_blocks Btype=",Btype,",X=",X,",Y=",Y);

	-+agent_mode(exploration);
	+have_block(Dir,B);
	-ava_dir(Dir);
	-stock(_,_,_);
	
	-location(block,Btype,X,Y);
	+block(Dir,Btype);
	attach(Dir);
	.

@move_to[atomic] 
+!move_to(X,Y,Btype): agent_location(MyN,MyX,MyY) & check_dir((X-MyX),(Y-MyY),Dir)<-
	.time(H,M,S,MS); 	
	.print("[",H,":",M,":",S,":",MS,"] ","the agent move to the dispenser Dir=:",Dir,",MyX=",MyX,",MyY=",MyY);
	//.print("[",H,":",M,":",S,":",MS,"] ","the agent move to the dispenser Dir=",Dir,",X=",X,",Y=",Y);
	//.print("[",H,":",M,":",S,":",MS,"] ","the agent move to the dispenser Dir=",Dir,",(X-MyX)=",(X-MyX),",(Y-MyY)=",(Y-MyY));
	if(Dir == null){
		.print("agent finished moving to ",",X=",X,",Y=",Y);
		!check_direction(X,Y,Btype);
		//!request_block(X,Y,Btype);
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

@move_on[atomic] 
+!move_on(X,Y): agent_location(MyN,MyX,MyY) & check_dir_on(X-MyX,Y-MyY,Dir) & current_task(N, D, R,TX,TY, B)<-
	.time(H,M,S,MS);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent move to the goal X:",X,",X=",Y);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent move to the goal MyX:",MyX,",MyY=",MyY);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent move to the goal (X-MyX):",(X-MyX),",(Y-MyY)=",(Y-MyY),",Dir=",Dir);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent move to current task N=",N,",D=", D,",R=", R,",TX=",TX,",TY=",TY,",B=", B);
	if (Dir == null){
		!rotate_direction(N, D, R,TX,-TY,B);
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

@discover_stock[atomic] 
+!discover_stock(Btype,X,Y) : not block(_,_)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent discover_stock1 Dtype=",Btype);
	-+stock(Btype,X,Y);
	-+agent_mode(find_blocks);
	.
@discover_stock2[atomic] 
+!discover_stock(Btype,X,Y) : block(_,Btype)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent discover_stock2 Dtype=",Btype);
	.

@stock[atomic] 
+!stock : not block(_,Dtype) & get_next_dispenser(Dtype,X,Y) <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent stock Dtype=",Dtype);
	-+stock(Dtype,X,Y);
	-+agent_mode(find_blocks);
	.
	
@thing1[atomic] 
+thing(X, Y, dispenser, Details) : agent_location(MyN,MyX,MyY) & not location(dispenser,Details,(MyX+X),(MyY+Y),DSeq) & dispenser_queue(DQ)<-
	.time(H,M,S,MS);
	.type(DQ,T);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a dispenser",",Details=",Details,",X=",X,",Y=",Y,",DQ=",DQ,",T=",T);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a dispenser",",Details=",Details,",MyX=",MyX,",MyY=",MyY);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a dispenser",",Details=",Details,",(MyX+X)=",(MyX+X),",(MyY+Y)=",(MyY+Y));
	
	if(MyX+X < 0 & MyY+Y < 0){
		+location(dispenser,Details,(MyX+X),(MyY+Y), ((MyX+X) * -1)+((MyY+Y) * -1));
		.concat(DQ,[((MyX+X) * -1)+((MyY+Y) * -1)],DQ2);
		-+dispenser_queue(DQ2);
	}elif(MyX+X > 0 & MyY+Y < 0){
		+location(dispenser,Details,(MyX+X),(MyY+Y), (MyX+X)+((MyY+Y) * -1));
		.concat(DQ,[(MyX+X)+((MyY+Y) * -1)],DQ2);
		-+dispenser_queue(DQ2);
	}elif(MyX+X < 0 & MyY+Y > 0){
		+location(dispenser,Details,(MyX+X),(MyY+Y), ((MyX+X) * -1)+(MyY+Y));
		.concat(DQ,[((MyX+X) * -1)+(MyY+Y)],DQ2);
		-+dispenser_queue(DQ2);
	}elif(MyX+X > 0 & MyY+Y > 0){
		+location(dispenser,Details,(MyX+X),(MyY+Y), MyX+X+MyY+Y);
		.concat(DQ,[MyX+X+MyY+Y],DQ2);
		-+dispenser_queue(DQ2);
	};
	
	!discover_stock(Details,(MyX+X),(MyY+Y));
	.
// @thing2[atomic] 
// +thing(X, Y, block, Details) : agent_location(MyN,MyX,MyY) & not location(block,Details,(MyX+X),(MyY+Y)) & get_dir(X,Y,Dir) & not block(Dir,Details)<-
// 	.time(H,M,S,MS);
// 	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a ",block,",Details=",Details,",X=",Y,",Y=",Y);
// 	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a ",block,",Details=",Details,",MyX=",MyX,",MyY=",MyY);
// 	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a ",block,",Details=",Details,",(MyX+X)=",(MyX+X),",(MyY+Y)=",(MyY+Y));
// 	+location(block,Details,(MyX+X),(MyY+Y));
// 	.

// agent see a goal
//+goal(X,Y): agent_location(MyN,MyX,MyY)  & count_location(goal,N) & (N == 0)<- 
//	+location(goal,_,(MyX+X),(MyY+Y));
//	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a goal:",(MyX+X),",",(MyY+Y));
//	.
@goal1[atomic] 
+goal(X,Y): agent_location(MyN,MyX,MyY) & not location(goal,_,(MyX+X),(MyY+Y),_) & goal_queue(GQ)<- 
	.time(H,M,S,MS);
	.type(GQ,T);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a goal:","X=",X,",Y=",Y,",GQ=",GQ,",T=",T);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a goal:",",MyX=",MyX,",MyY=",MyY);
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a goal:",",(MyX+X)=",(MyX+X),",(MyY+Y)=",(MyY+Y));
	if(MyX+X < 0 & MyY+Y < 0){
		+location(goal,_,(MyX+X),(MyY+Y), ((MyX+X) * -1)+((MyY+Y) * -1));
		.concat(GQ,[((MyX+X) * -1)+((MyY+Y) * -1)],GQ2);
		-+goal_queue(GQ2);
	}elif(MyX+X > 0 & MyY+Y < 0){
		+location(goal,_,(MyX+X),(MyY+Y), (MyX+X)+((MyY+Y) * -1));
		.concat(GQ,[(MyX+X)+((MyY+Y) * -1)],GQ2);
		-+goal_queue(GQ2);
	}elif(MyX+X < 0 & MyY+Y > 0){
		+location(goal,_,(MyX+X),(MyY+Y), ((MyX+X) * -1)+(MyY+Y));
		.concat(GQ,[((MyX+X) * -1)+(MyY+Y)],GQ2);
		-+goal_queue(GQ2);
	}elif(MyX+X > 0 & MyY+Y > 0){
		+location(goal,_,(MyX+X),(MyY+Y), MyX+X+MyY+Y);
		.concat(GQ,[MyX+X+MyY+Y],GQ2);
		-+goal_queue(GQ2);
	};
	.
@goal2[atomic] 
+location(goal,_,X,Y): task_base(N, D, R,TX,TY,B) & block(Bdir,B) & not current_task(_,_,_,_,_,_) & not conflict_task(N)<- 
	.time(H,M,S,MS); 	
	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees a goal1:",X,",",Y);
	
	.broadcast(tell,conflict_task(N));
	+current_task(N, D, R,TX,TY, B);
	-+agent_mode(find_goal);
	.print("[",H,":",M,":",S,":",MS,"] ","1--------------------------- agent start task=",N);
	.
	
@have_block[atomic] 
+have_block(Dir,B) : location(goal,_,GoalX,GoalY,_) & task_base(N, D, R,TX,TY,B) & block(Dir,B) & not current_task(_,_,_,_,_,_) & not conflict_task(N)<-
	
	.broadcast(tell,conflict_task(N));
	+current_task(N, D, R,TX,TY, B);
	-+agent_mode(find_goal);
	.time(H,M,S,MS);
	.print("[",H,":",M,":",S,":",MS,"] ","3--------------------------- agent start task=",N);
	-have_block(Dir,B);
	.

+task(N, D, R, Req) : (.length(Req) == 1) & not task_base(N,_,_,_,_,_)<-
	.member(req(TX,TY,B),Req);
	.print("agent add task_base--------",",B=", B,",X=", TX,",Y=",TY,",N=",N);
	+task_base(N, D, R,TX,TY,B);
	.
@task_base[atomic] 
+task_base(N, D, R,TX,TY,B) : location(goal,_,GoalX,GoalY,_) & block(Dir,B) & not current_task(_,_,_,_,_,_) & not conflict_task(N)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent receive a new task ",N,",D=", D,",R=", R,",B=", B,",X=", TX,",Y=",TY);
	.broadcast(tell,conflict_task(N));
	+current_task(N, D, R,TX,TY, B);
	-+agent_mode(find_goal);
	.print("[",H,":",M,":",S,":",MS,"] ","4--------------------------- agent start task=",N);
	.
	


+conflict_task(N)[source(Ag)]  :  Ag \== self <- 
	+conflict_task(N);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","Received tell conflict task name ",N," from ", Ag);
	.

// agent see a obstacle
//+obstacle(X,Y): agent_location(MyN,MyX,MyY) & count_location(obstacle,N) & (N == 0) <- 
//	+location(obstacle,_,(MyX+X),(MyY+Y));
//	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees an obstacle :",(MyX+X),",",(MyY+Y));
//	.
//+obstacle(X,Y): agent_location(MyN,MyX,MyY) & location(obstacle,_,ObsX,ObsY) <- 
//	if(not (ObsX == (MyX+X)) & not (ObsY == (MyY+Y))){
//		+location(obstacle,_,(MyX+X),(MyY+Y));
//		.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","the agent sees an obstacle :");
//	};
//	.

@move_exploration[atomic]
+lastAction(move) : agent_mode(exploration) & lastActionResult(failed_path) & lastActionParams(Params) & agent_location(MyN,MyX,MyY) & .random(R1) & .random(R2) & .random(R3) & get_random_pointX(R1,X1) & get_random_pointY(R2,R3,X1,X,Y)<-
	.member(V,Params);
	if(V == n){
		-+agent_location(MyN,MyX,MyY+1);
	}elif(V == e){
		-+agent_location(MyN,MyX-1,MyY);
	}elif(V == s){
		-+agent_location(MyN,MyX,MyY-1);
	}elif(V == w){
		-+agent_location(MyN,MyX+1,MyY);
	};
	-+random_point(X+MyX,Y+MyY);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","------------lastaction failed:",V)
	.
@move_find_blocks[atomic]
+lastAction(move) : agent_mode(find_blocks) & get_next_dispenser(Dtype,X,Y) & lastActionResult(failed_path) & lastActionParams(Params) & agent_location(MyN,MyX,MyY)<-
	.member(V,Params);
	if(V == n){
		-+agent_location(MyN,MyX,MyY+1);
	}elif(V == e){
		-+agent_location(MyN,MyX-1,MyY);
	}elif(V == s){
		-+agent_location(MyN,MyX,MyY-1);
	}elif(V == w){
		-+agent_location(MyN,MyX+1,MyY);
	};
	!discover_stock(Dtype,X,Y);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","---find_blocks---------lastaction failed:",V)
	.
@move_find_goal[atomic]
+lastAction(move) : agent_mode(find_goal) & lastActionResult(failed_path) & lastActionParams(Params) & agent_location(MyN,MyX,MyY)<-
	.member(V,Params);
	if(V == n){
		-+agent_location(MyN,MyX,MyY+1);
	}elif(V == e){
		-+agent_location(MyN,MyX-1,MyY);
	}elif(V == s){
		-+agent_location(MyN,MyX,MyY-1);
	}elif(V == w){
		-+agent_location(MyN,MyX+1,MyY);
	};
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","---find_goal---------lastaction failed:",V)
	.
@move_exploration_failed_forbidden[atomic]
+lastAction(move) : agent_mode(exploration) & lastActionResult(failed_forbidden) & lastActionParams(Params) & agent_location(MyN,MyX,MyY) & .random(R1) & .random(R2) & .random(R3) & get_random_pointX(R1,X1) & get_random_pointY(R2,R3,X1,X,Y)<-
	.member(V,Params);
	if(V == n){
		+boundary(n,MyY);
		-+agent_location(MyN,MyX,MyY+1);
	}elif(V == e){
		+boundary(e,MyX);
		-+agent_location(MyN,MyX-1,MyY);
	}elif(V == s){
		+boundary(s,MyY);
		-+agent_location(MyN,MyX,MyY-1);
	}elif(V == w){
		+boundary(s,MyX);
		-+agent_location(MyN,MyX+1,MyY);
	};
	-+random_point(X+MyX,Y+MyY);
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent reached the boundary:",V)
	.
@submit_success[atomic]
+lastAction(submit) : lastActionResult(success) & lastActionParams(Params) & .member(N,Params)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent submit task success--------------------N=",N);
	-task_base(N, D, R,TX,TY, B);
	-+agent_mode(exploration);
	!stock;
	.
@submit_failed[atomic]
+lastAction(submit) : lastActionResult(failed) & lastActionParams(Params) & .member(N,Params) & task_base(N, D, R,TX,TY, B) & get_dir(TX,TY,Dir) & block(Dir,B)<-
	
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent submit task failed--------------------N=",N);
	-task_base(N, D, R,TX,TY, B);
	+block(Dir,B);
	-ava_dir(Dir);
	-+agent_mode(exploration);
	!stock;
	.
@request_failed_blocked[atomic]
+lastAction(request) : lastActionResult(failed_blocked) <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent request failed-------failed_blocked-------------");
	-+agent_mode(exploration);
	.
@request_failed_target[atomic]
+lastAction(request) : lastActionResult(failed_target) <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent request failed--------failed_target------------");
	-+agent_mode(exploration);
	.
@attach_failed_target[atomic]
+lastAction(attach) : lastActionResult(failed_target) <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent attach failed-------failed_target-------------");
	-+agent_mode(exploration);
	.
@attach_failed[atomic]
+lastAction(attach) : lastActionResult(failed) <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent attach failed--------failed------------");
	-+agent_mode(exploration);
	.
@rotate_failed[atomic]
+lastAction(rotate) : lastActionResult(failed) & lastActionParams(Params) & .member(Rdir,Params)<-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","agent rotate failed--------failed------------");
	if(Rdir == cw){
		!update_block_dir(ccw);
	}elif(Rdir == ccw){
		!update_block_dir(cw);
	};
	.

	
+agent_location(N,X,Y) : true <-
	.time(H,M,S,MS); 	.print("[",H,":",M,":",S,":",MS,"] ","add self location inspect :",N,",",X,",",Y);
	//true;
	.
