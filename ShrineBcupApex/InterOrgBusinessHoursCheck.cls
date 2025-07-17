public without sharing class InterOrgBusinessHoursCheck {
    @TestVisible
    private static String testDay;
    @TestVisible
    private static Datetime testCurrentDt;

    public class BusinessHoursWrapper {
        @InvocableVariable
        public Boolean isWithinBusinessHours;

        public BusinessHoursWrapper(Boolean isWithinBusinessHours) {
            this.isWithinBusinessHours = isWithinBusinessHours;
        }
    }

    @InvocableMethod(
        label='Check Business Hours for Any Org'
        description='Checks the business hours in a destination org'
    )
    public static List<BusinessHoursWrapper> checkBusinessHours(List<String> orgs) {
        // Begin callout with REST API query
        InterOrgChatCallout.beginInterOrgChatCallout(
            orgs[0],
            'GET',
            '/services/data/v51.0/query/?q=SELECT+Id,IsActive,TimeZoneSidKey' +
                ',SundayStartTime,SundayEndTime' +
                ',MondayStartTime,MondayEndTime' +
                ',TuesdayStartTime,TuesdayEndTime' +
                ',WednesdayStartTime,WednesdayEndTime' +
                ',ThursdayStartTime,ThursdayEndTime' +
                ',FridayStartTime,FridayEndTime' +
                ',SaturdayStartTime,SaturdayEndTime' +
                '+FROM+BusinessHours+WHERE+Name+=+\'' +
                orgs[0] +
                '\'' +
                '+AND+IsActive+=+true',
            null
        );
        InterOrgChatCallout.useLiveAgentApiEndpoint = false;
        InterOrgChatCallout.queries = null;
        HttpResponse businessHoursResponse = InterOrgChatCallout.sendRequest();
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(
            businessHoursResponse.getBody()
        );
        BusinessHoursWrapper wrapper = new BusinessHoursWrapper(checkIfOutsideBusinessHours(parsedResponse));

        return new List<BusinessHoursWrapper>{ wrapper };
    }

    @TestVisible
    public static Boolean checkIfOutsideBusinessHours(Map<String, Object> parsedResponse) {
        // Cast records into a list, then into a map for easy access of business hour values
        Map<String, Object> mapBusHoursFieldToValue = (Map<String, Object>) ((List<Object>) parsedResponse.get(
            'records'
        ))[0];

        // Default to outside business hours until proven otherwise
        Boolean isWithinBusinessHours = false;

        // **Get day of week in order to retrieve correct business hours
        // (1) Convert System.now() to target timezone in string format to
        // get the correct date
        Datetime currentDt = (Test.isRunningTest() && (testCurrentDt != null)) ? testCurrentDt : System.now();
        String strNowInTargetTimezone = currentDt.format(
            'yyyy-MM-dd HH:mm:ss',
            (String) mapBusHoursFieldToValue.get('TimeZoneSidKey')
        );

        // (2) Construct datetime in order to get the formatted day of week. We're constructing it with
        // the target datetime string. We don't care about the time, just the date.
        Integer year = Integer.valueOf(strNowInTargetTimezone.substringBefore('-'));
        Integer day = Integer.valueOf(strNowInTargetTimezone.substringAfterLast('-').substringBefore(' '));
        Integer month = Integer.valueOf(strNowInTargetTimezone.substringAfter('-').substringBeforeLast('-'));
        Datetime nowInTargetTimezone = Datetime.newInstance(year, month, day);

        // (3) Manually set day of week if in test context, otherwise format real-time day of week
        //String dayOfWeek = (Test.isRunningTest() && (String.isNotBlank(testDay))) ? testDay : nowInGmtTimezone.format('EEEE');
        String dayOfWeek = (Test.isRunningTest() && (String.isNotBlank(testDay)))
            ? testDay
            : nowInTargetTimezone.format('EEEE');

        // Check if current datetime is between start and end times of target business hours. Set
        // all datetimes to GMT timezone so we're comparing in one timezone. If inside business hours
        // or it's a 24-hour business hour day, set output variable to true
        Datetime dateTimeToCompare = Datetime.valueOfGmt(strNowInTargetTimezone);

        string strTime = (String) mapBusHoursFieldToValue.get(dayOfWeek + 'StartTime');
        Datetime businessHoursStartDt = Datetime.valueOfGmt(
            strNowInTargetTimezone.substringBefore(' ') + ' ' + (string.isBlank(strTime) ? '00:00:00.000Z' : strTime)
        );

        strTime = (String) mapBusHoursFieldToValue.get(dayOfWeek + 'EndTime');
        Datetime businessHoursEndDt;
        if (string.isBlank(strTime)) {
            businessHoursEndDt = businessHoursStartDt.addMinutes(1);
        } else {
            businessHoursEndDt = Datetime.valueOfGmt(strNowInTargetTimezone.substringBefore(' ') + ' ' + strTime);
        }

        if (
            (dateTimeToCompare >= businessHoursStartDt && dateTimeToCompare <= businessHoursEndDt) ||
            (businessHoursStartDt == businessHoursEndDt)
        ) {
            isWithinBusinessHours = true;
        }

        return isWithinBusinessHours;
    }
}