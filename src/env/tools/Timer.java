package tools;

import java.text.SimpleDateFormat;
import java.util.Date;

import cartago.*;

public class Timer extends Artifact {

    @OPERATION
    public void getTime(OpFeedbackParam<Long> outValue) {
        outValue.set(new Date().getTime());
    }

    @OPERATION
    public void updateReputation(long startTime, String deadline, int reputation,
            OpFeedbackParam<Double> outValue) throws Exception {

        Date date = new Date();
        long timeRemaining = parseToMillis(deadline) - date.getTime();

        if (timeRemaining > 0) {
            outValue.set(reputation + threeDecimals(1000.0 / (date.getTime() - startTime)));
        } else {
            outValue.set(reputation - 1.0);
        }
    }

    private long parseToMillis(String date) throws Exception {
        return new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").parse(date).getTime();
    }

    private double threeDecimals(double number) {
        return Math.round(number * 1000.0) / 1000.0;
    }

}
