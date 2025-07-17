public class DepositSummaryController {

    public String runDate { get; set; }
    public String runTime { get; set; }
    public String transDate { get; set; }
    public String depositDate { get; set; }
    public String fleetAccount { get; set; }
    public String trackingNumber { get; set; }

    public DepositSummaryController() {
        runDate = '09/04/2024';
        runTime = '12:30 PM';
        transDate = '09/04/2024 - 09/04/2024';
        depositDate = '09/04/2024';
        fleetAccount = '1838644';
        trackingNumber = '9';
    }
}