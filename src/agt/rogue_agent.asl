// Agent rogue_agent in project exercise-9

/* Initial beliefs and rules */
// initially, the agent believes that it hasn't received any temperature readings
// gradually, the list will fill, e.g., received_readings([])
//received_readings([]).

/* Initial goals */
!set_up_plans.

// Plan for replacing the inherited behavior for read_temperature with a behavior
// that serves the Rogues and the Rogue Leader
+!set_up_plans : true
<-
  // remove plans for reading the temperature with the weather station
  .relevant_plans({ +!read_temperature }, _, LL);
  .remove_plan(LL);
  .relevant_plans({ -!read_temperature }, _, LL2);
  .remove_plan(LL2);

  // add a new plan for reading the temperature that doesn't require contacting the weather station
  // the agent will pick one of the first three temperature readings that have been broadcasted,
  // it will slightly change the reading, and boradcast it
  /*
  .add_plan({ +!read_temperature : received_readings(TempReadings) &
    .length(TempReadings) >=3
    <-
      .print("I will read the temperature");
      .print("Received temperature readings: ", TempReadings);

      // pick one of the 3 first received readings randomly
      .random([0,1,2], SourceIndex);
      .nth(SourceIndex, TempReadings, Celcius);

      // add a small deviation to the selected temperature reading
      .random(Deviation);

      // broadcast the temperature
      .print("Temperature Reading (Celcious): ", Celcius + Deviation);
      .broadcast(tell, temperature(Celcius + Deviation)) });

  // add plan for reading temperature in case fewer than 3 readings have been received
  .add_plan({ +!read_temperature : received_readings(TempReadings) &
    .length(TempReadings) <3
    <-

    // wait for 2 sec and find all beliefs about received temperature readings
    .wait(2000);
    .findall(TempReading, temperature(TempReading)[source(Ag)], NewTempReadings);

    // update the belief about all reaceived temperature readings
    -+received_readings(NewTempReadings);

    // try again to "read" the temperature
    !read_temperature });
    */

  // Task 2
  .add_plan({ +!read_temperature : temperature(TempValue)[source(sensing_agent_9)]
    <-

    .print("Mirror rogue leader");
    .print("Temperature Reading (Celcius): ", TempValue);
    .broadcast(tell, temperature(TempValue)) });

  // Try again 
  .add_plan({ +!read_temperature : true
    <-
    .wait(2000);
    !read_temperature });
    
  .add_plan({
    +sendCertificate[source(Src)] : true
    <-
      .print("Sending fake certificate to ", Src);
      .send(Src, tell, certified_reference(rating(sensing_agent_9, certification_agent, quality, temperature(10), 1.0), signedBy(certification_agent)));
  }).


{ include("sensing_agent.asl")}
