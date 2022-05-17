package tools;

import cartago.*;

public class Converter extends Artifact {

    @OPERATION
    public void convert(double sourceMin, double sourceMax, double targetMin, double targetMax, double value,
            OpFeedbackParam<Double> newValue) {

        double sourceRange = sourceMax - sourceMin;
        double targetRange = targetMax - targetMin;

        double rescaledValue = (value - sourceMin) / sourceRange;

        rescaledValue *= targetRange;
        rescaledValue += targetMin;

        newValue.set(rescaledValue);
        log("CONVERTER: " + value + " was rescaled to " + rescaledValue);
    }
}
