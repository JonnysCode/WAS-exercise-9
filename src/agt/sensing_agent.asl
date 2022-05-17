// Agent sensing_agent in project exercise-9

/* Initial beliefs and rules */
role_goal(R, G) :-
	role_mission(R, _, M) & mission_goal(M, G).

can_achieve (G) :-
	.relevant_plans({+!G[scheme(_)]}, LP) & LP \== [].	

i_have_plans_for(R) :-
	not (role_goal(R, G) & not can_achieve(G)).

/* Initial goals */
!start.

// Initialisation Plan
@start
+!start : true
<-
	.my_name(Me);
	.print("Hello from ",Me).

// Plan to achieve reading the air temperature using a robotic arm
+!read_temperature : true 
<-
	/* Rate limited
	makeArtifact("weatherStation", "wot.ThingArtifact", ["https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/weather-station.ttl"], WeatherStatArtId);
  	focus(WeatherStatArtId);

	readProperty("Temperature", _, OutValues);
	.nth(0, OutValues, TempValue);
	*/

	.broadcast(tell, temperature(23.4));
	.print("Agent temperature reading (Celcius): ", 23.4).

/*
	Relevant for Exercise 9 Task 2
	React to an event of a certified reference that includes a rating signed by
	and agent. The agent reacts by printing the certified reference.

	A: The agent who has been rated
	B: The agent who interacted with agent A and provided the rating
	C: The term for which the rating was given (e.g. quality, honesty)
	I: The interaction to which agents A and B participated
	V: The rating. The range of the rating is [-1,1]

	 Ag: The agent who signed the reference. Ag does not need be equal to A or B.
*/
+certified_reference(rating(A, B, C, I, V), signedBy(Ag)) : true
<-
	.print("Received a certified reference from ", Ag, ": New ", C, " rating ", V, " for agent ", B, " who interacted with agent ", A, " in interaction ", I).


+sendCertificate[source(Src)] : certified_reference(rating(A, B, C, I, V), signedBy(Ag)) & V > 0.0
<-
	.print("Sending certificate to ", Src);
	.send(Src, tell, certified_reference(rating(A, B, C, I, V), signedBy(Ag))).


+deployedOrg(OrgName, GroupName): true <-
	.print("Joining deployed org: ", OrgName);

	lookupArtifact(OrgName, OrgArtId);
	focus(OrgArtId);

	lookupArtifact(GroupName, GrpArtId);
	focus(GrpArtId);

	!adoptRoles(GrpArtId).


+!adoptRoles(G) : role(R, _) & i_have_plans_for(R)
<- 
	.print("Adopting role: ", R);
	adoptRole(R).


+obligation(Ag, MCond, committed(Ag, Mission, Scheme), Deadline) : .my_name(Ag)
<-
  .print("Commited to Mission: ", Mission);
  commitMission(Mission)[artifact_name(Scheme)];
  lookupArtifact(Scheme, SchemeArtId);
  focus(SchemeArtId).


+obligation(Ag, MCond, done(Scheme,Goal,Ag), Deadline) : .my_name(Ag)
<-
  .print("Done with goal: ", Goal);
  !Goal[scheme(Scheme)];
  goalAchieved(Goal)[artifact_name(Scheme)].


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// Uncomment if you want to use the organization rules available in https://github.com/moise-lang/moise/blob/master/src/main/resources/asl/org-rules.asl
{ include("$moiseJar/asl/org-rules.asl") }

{ include("inc/skills-extended.asl") }
