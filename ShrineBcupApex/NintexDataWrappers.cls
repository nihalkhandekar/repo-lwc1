global with sharing class NintexDataWrappers {

    global class AcknowledgementTemplateWrapper{
        public String principalTitle;
    }
    
    global class ARCurrentPrincipalInfoWrapper{
        public String principalName;
        public String principalDesignation;
        public String principalTitle;
        public String principalBusinessAddr;
        public String principalResidenceAddr;
    }

    global class BusinessPrimaryLocationDetailsWrapper{
        public String businessCitizenship;
        public String businessType;
        public String businessName;
        public String businessALEI;
        public String dateOfOrgMeeting;
        public String businessEmailOld;
        public String businessEmailNew;
        public String naicsOld;
        public String naicsNew;
        public String principalOffcAddrOld;
        public String principalOffcAddrNew;
        public String mailingAddrOld;
        public String mailingAddrNew;
        public String offcInJurisdictionAddrOld;
        public String offcInJurisdictionAddrNew;
        public String mailingStateOfFormationOld;
        public String mailingStateOfFormationNew;
    }

    global class BusinessAcknowledgementWrapper {
        public String designatorsNameLabel;
        public String designatorsName;
        public String designatorsTitleLabel;
        public String designatorsTitle;
    }

    global class LongformRejectReasonWRIT {
        public String sResponse;
    }
          global class filingDescriptionValueInfo {
        public String filingDescription;
        public String filingValue;
    }
}