package model;

import java.sql.Timestamp;

public class MLPrediction {
    private int predictionId;
    private int potId;
    private Timestamp predictedDryTime; // Thời điểm dự đoán chậu sẽ khô
    private double confidenceScore;     // Độ tin cậy của thuật toán (0 - 100%)
    private String featuresUsed;        // Các chỉ số dùng để đoán (VD: Moisture, Light)
    private Timestamp predictedAt;

    public MLPrediction() {}

    public MLPrediction(int predictionId, int potId, Timestamp predictedDryTime, double confidenceScore, String featuresUsed, Timestamp predictedAt) {
        this.predictionId = predictionId;
        this.potId = potId;
        this.predictedDryTime = predictedDryTime;
        this.confidenceScore = confidenceScore;
        this.featuresUsed = featuresUsed;
        this.predictedAt = predictedAt;
    }

    // --- GETTER & SETTER ---
    public int getPredictionId() { return predictionId; }
    public void setPredictionId(int predictionId) { this.predictionId = predictionId; }
    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }
    public Timestamp getPredictedDryTime() { return predictedDryTime; }
    public void setPredictedDryTime(Timestamp predictedDryTime) { this.predictedDryTime = predictedDryTime; }
    public double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }
    public String getFeaturesUsed() { return featuresUsed; }
    public void setFeaturesUsed(String featuresUsed) { this.featuresUsed = featuresUsed; }
    public Timestamp getPredictedAt() { return predictedAt; }
    public void setPredictedAt(Timestamp predictedAt) { this.predictedAt = predictedAt; }
}