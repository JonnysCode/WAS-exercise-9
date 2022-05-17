// Agent org_agent in project exercise-8

/* Initial beliefs and rules */
org_name("lab_monitoring_org").
group_name("monitoring_team").
sch_name("monitoring_scheme").

has_enough_players_for(R) :-
  role_cardinality(R, Min, Max) &
  .count(play(_,R,_),NP) &
  NP >= Min.

/* Initial goals */
!start.

// Initialisation Plan
@start
+!start : org_name(OrgName) &
  group_name(GroupName) &
  sch_name(SchemeName)
<-
  .print("I will initialize an organization ", OrgName, " with a group ", GroupName, " and a scheme ", SchemeName, " in workspace ", OrgName);

  makeArtifact("timer", "tools.Timer", [], TimerArtId);
  focus(TimerArtId)

  makeArtifact("crawler", "tools.HypermediaCrawler", ["581b07c7dff45162"], CrawlerArtId);
  focus(CrawlerArtId);
  searchEnvironment("Monitor Temperature", FilePath);
  .print("File is at ", FilePath);

  makeArtifact(OrgName, "ora4mas.nopl.OrgBoard", [FilePath], OrgArtId);
  focus(OrgArtId);

  createGroup(GroupName, GroupName, GrpArtId);
  focus(GrpArtId);
  createScheme(SchemeName, SchemeName, SchArtId);
  focus(SchArtId);

  .broadcast(tell, deployedOrg(OrgName, GroupName));

  !manageFormation(OrgName, GroupName);
  addScheme(SchemeName)[artifact_id(GrpArtId)].

// Plan to add an organization artifact to the inspector_gui
// You can use this plan after creating an organizational artifact so that you can inspect it
+!inspect(OrganizationalArtifactId) : true
<-
  debug(inspector_gui(on))[artifact_id(OrganizationalArtifactId)].

// Plan to wait until the group managed by the Group Board artifact G is well-formed
// Makes this intention suspend until the group is believed to be well-formed
+?formationStatus(ok)[artifact_id(G)] : group(GroupName,_,G)[artifact_id(OrgName)]
<-
  .print("Waiting for group ", GroupName," to become well-formed")
  .wait({+formationStatus(ok)[artifact_id(G)]}).

// Plan to react on events about an agent Ag adopting a role Role defined in group GroupId
+play(Ag, Role, GroupId) : false
<-
  .print("Agent ", Ag, " adopted the role ", Role, " in group ", GroupId).


+play(Ag, Role, GroupId) : true
<-
  if (not reputation(Ag, Reputation)) {
    +reputation(Ag, 0);
    .print("Agent ", Ag, " adopted role ", Role, " in group ", GroupId, " with Reputation of ", 0);
  } else {
    .print("Agent ", Ag, " adopted role ", Role, " in group ", GroupId, " with Reputation of ", Reputation);
  }.


+!manageFormation(OrgName, GroupName) : role(R, _) & not has_enough_players_for(R)
<-
  .print("Searching for Role: ", R);
  .broadcast(tell, availableRole(OrgName, GroupName, R) ); 
  .wait(5000);
  !manageFormation(OrgName, GroupName).


+!manageFormation(OrgName, GroupName): formationStatus(ok)
<-
  .print("All roles are present").


+!manageFormation(OrgName, GroupName): true
<-
  .print("Formation failed").


// EX8: Start mission once agents commits
+obligation(Ag, MCond, committed(Ag,Mission,Scheme), Deadline) : true 
<-
  getTime(Time);
  +missionStarted(Ag, Time);
  .print("Starting mission: ", Mission, " at ", Time).


// EX8: Update reputation once agent achieves Goal
+oblFulfilled(obligation(Ag, MCond, done(Scheme,Goal,Ag), Deadline)) :
  missionStarted(Ag, StartTime) &
  reputation(Ag, Reputation)
<-
  updateReputation(StartTime, Deadline, Reputation, NewReputation);
  -reputation(Ag, Reputation);
  +reputation(Ag, NewReputation); 
  .print("Reputation of Agent ", Ag, " updated to ", NewReputation).



// Additional behavior
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// Uncomment if you want to use the organization rules available in https://github.com/moise-lang/moise/blob/master/src/main/resources/asl/org-rules.asl
{ include("$moiseJar/asl/org-rules.asl") }
