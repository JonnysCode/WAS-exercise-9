package tools;

import cartago.*;
import java.util.Arrays;
import java.util.stream.DoubleStream;
import java.lang.Math;

/**
 * An SDBasedEvaluator helps with evaluating how much values deviate
 * from their mean value in terms of standard deviations
 */
public class SDBasedEvaluator extends Artifact {

  /**
   * CArtAgO operation for evaluating how many standard deviations each value from
   * an array
   * deviates from the mean (as calculated by the values of the array).
   * 
   * @param values       An array of values
   * @param deviations   The calculated array of deviations (computed in standard
   *                     deviations). Each deviation corresponds to how many
   *                     standard
   *                     deviations the corresponding value deviates from the
   *                     mean.
   * @param minDeviation The minimum deviation found in deviations
   * @param maxDeviation The maximum deviation found in deviations
   */
  @OPERATION
  public void evaluateDeviations(Object[] values, OpFeedbackParam<Double[]> deviations,
      OpFeedbackParam<Double> minDeviation, OpFeedbackParam<Double> maxDeviation) {

    // sum of all values
    double sum = 0.0;

    // mean of all values
    double mean = 0.0;

    // standard deviation of all values
    double sd = 0.0; // helper
    double standardDeviation = 0.0;

    // number of values
    int valuesNum = values.length;

    // deviations from the mean in terms of standard valueDeviations
    // i.e. how many standard deviations each value deviates from the mean
    Double[] valueDeviationsToSort = new Double[valuesNum]; // helper
    Double[] valueDeviations = new Double[valuesNum];

    // calculate the sum of all values
    for (int i = 0; i < valuesNum; i++) {
      sum = sum + Double.valueOf(values[i].toString());
    }

    // calculate the mean of values
    mean = sum / (valuesNum);

    // calculate the standard deviation
    for (int i = 0; i < valuesNum; i++) {
      sd = sd + Math.pow((Double.valueOf(values[i].toString()) - mean), 2);
    }
    standardDeviation = Math.sqrt(sd / valuesNum);

    // uncomment to observe the standard deviation or the mean
    // System.out.println("Standard Deviation: "+ standardDeviation);
    // System.out.println("Mean: "+ mean);

    // calculate how many standard deviations each value deviates from mean
    // all deviations are stored in an array
    for (int i = 0; i < valuesNum; i++) {
      valueDeviations[i] = Math.abs(mean - Double.valueOf(values[i].toString())) / standardDeviation;
    }

    // sort the deviations in aschending order
    for (int i = 0; i < valuesNum; i++) {
      valueDeviationsToSort[i] = valueDeviations[i];
    }
    Arrays.sort(valueDeviationsToSort);

    // the minimum deviation in deviations
    double minValueDeviation = valueDeviationsToSort[0];

    // the maximum deviation in deviations
    double maxValueDeviation = valueDeviationsToSort[valuesNum - 1];

    // set the deviations to be returned to the caller
    deviations.set(valueDeviations);

    // set the minimum deviation in deviations to be returned to the caller
    minDeviation.set(minValueDeviation);

    // set the maximum deviation in deviations to be returned to the caller
    maxDeviation.set(maxValueDeviation);
  }

  @OPERATION
  public void avg(Object[] values, OpFeedbackParam<Double> avg) {

    Double sum = Arrays.stream(values).mapToDouble(v -> Double.valueOf(v.toString())).sum();
    log("SUM: " + sum);

    avg.set(sum / (double) values.length);
  }
}
