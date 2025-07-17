public without sharing class ChartDataController {
    @AuraEnabled(cacheable=true)
    public static List<ChartData> getChartData1() {
        // Create a list to hold the chart data
        List<ChartData> chartData = new List<ChartData>();

        // Populate the chart data
        chartData.add(new ChartData('Label 1', 19, 29, 35));
        chartData.add(new ChartData('Label 2', 12, 20, 21));
        chartData.add(new ChartData('Label 3', 12, 20, 50));
        chartData.add(new ChartData('Label 4', 17, 44, 45));
        chartData.add(new ChartData('Label 5', 5, 30, 25));

        return chartData;
    }

    @AuraEnabled(cacheable=true)
    public static List<ChartData> getChartData2() {
        // Create a list to hold the chart data
        List<ChartData> chartData = new List<ChartData>();

        // Populate the chart data
        chartData.add(new ChartData('Label 1',22,25,13));
        chartData.add(new ChartData('Label 2',32,27,12));
        chartData.add(new ChartData('Label 3',45,12,7));
        chartData.add(new ChartData('Label 4',23,44,45));
        // chartData.add(new ChartData('Label 5',15,30,25));

        return chartData;
    }

    // Inner class representing the chart data
    public class ChartData {
        @AuraEnabled public String label;
        @AuraEnabled public Integer xValue;
        @AuraEnabled public Integer yValue;
        @AuraEnabled public Integer zValue;

        // Constructor
        public ChartData(String label, Integer xValue, Integer yValue, Integer zValue) {
            this.label = label;
            this.xValue = xValue;
            this.yValue = yValue;
            this.zValue = zValue;
        }
    }

    
}