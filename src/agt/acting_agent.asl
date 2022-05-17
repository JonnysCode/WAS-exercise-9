// Agent acting_agent in project exercise-9

/* Initial beliefs and rules */
role_goal(R, G) :-
	role_mission(R, _, M) & mission_goal(M, G).

can_achieve (G) :-
	.relevant_plans({+!G[scheme(_)]}, LP) & LP \== [].

i_have_plans_for(R) :-
    not (role_goal(R, G) & not can_achieve(G)).

all_temperature_readings_received :-
	.count(temperature(_)[source(_)], N) & N == 9.

/* Initial goals */
!start.

// Initialisation Plan
@start
+!start : true
<- 	.my_name(Me);
	.print("Hello from ",Me);
	makeArtifact("converter", "tools.Converter", [], ConverterArtId);
  	focus(ConverterArtId).

// Plan to achieve manifesting the air temperature using a robotic arm
+!manifest_temperature : all_temperature_readings_received
<-
	.print("Received all temperature readings");
	!caluculateRatings;
	!findBestRating;
	!writeTemperature.


+!caluculateRatings : .my_name(Me)
<-
	.findall([X, Y], temperature(X)[source(Y)], TempAgValues);
	.findall(K, .member([K, _], TempAgValues), TempValues);
	.findall(K, .member([_, K], TempAgValues), AgValues);

	.print(TempValues);
	.print(AgValues);

	makeArtifact("standardCalc", "tools.SDBasedEvaluator", [], StdArtId);
	evaluateDeviations(TempValues, Deviations, MinDeviation, MaxDeviation);

	for ( .range(I, 0, (.length(TempValues) - 1)) ) {
        .nth(I, TempValues, Temp);
        .nth(I, AgValues, Ag);
		.nth(I, Deviations, Std);
		.print("Agent: ", Ag, ", Temperature: ", Temp, ", Std: ", Std);
		
		convert(1/MaxDeviation, 1/MinDeviation, -1, 1, 1/Std, Rating);
		+rating(Ag, Me, quality, temperature(Temp)[source(_)], Rating);
    }.


+!findBestRating : true
<-
	.findall([R, A], rating(A, _, _, _, R), AgRatingValues);

	.max(AgRatingValues, Max);
	.nth(0, Max, R);
	.nth(1, Max, Ag);

	+bestRating(Ag, R);
	.print("Added best Rating for: ",  Ag, " with Rating: ", R).


+!writeTemperature : bestRating(Ag, R) & temperature(TempValue)[source(Ag)]
<-
	.print("Agent ", Ag, " has the best rating of ", R);
	.print("Temperature manifesting using leubot: ", TempValue);
	convert(-20, 30, 200, 830, TempValue, ConvertedValue);
	.print("Converted value ", ConvertedValue);
	makeArtifact("leubot", "wot.ThingArtifact", ["https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/leubot1.ttl", true], LeubotId);
	setAPIKey("1a313a6c5340caf9d3dc51bab400e318");
	invokeAction("setWristAngle", ["value"], [ConvertedValue]).

/*
	The agent reacts when a new rating is added to its belief base by printing a relevant message
	A: The agent who has been rated
	B: The agent who interacted with agent A and provided the rating
	C: The term for which the rating was given (e.g. quality, honesty)
	I: The interaction to which agents A and B participated
	V: The rating. The range of the rating is [-1,1]
*/
+rating(A, B, C, I, V): true
<-
	.print("New ", C, " rating ", V, " for agent ", B, " who interacted with agent ", A, " in interaction ", I).


+availableRole(OrgName, GroupName, R) : i_have_plans_for(R) & .my_name(Me)
<-
	lookupArtifact(OrgName, OrgArtId);
	focus(OrgArtId);

	lookupArtifact(GroupName, GrpArtId);
	focus(GrpArtId);

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
