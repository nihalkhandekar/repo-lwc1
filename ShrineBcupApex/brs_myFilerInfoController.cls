public with sharing class brs_myFilerInfoController {
    @AuraEnabled
    public static ContactInfo getContactInfo() {
        Id userContactId = [select Id, contactId from User where Id = : UserInfo.getUserId()].contactId;
        Contact con = [select Id,MailingStreet, MailingCity, MailingState, MailingCountry, MailingAddress,MailingPostalcode ,Organization__c,Mailing_International_Address__c,Mailing_Address_Format__c from Contact where Id=:userContactId];
        ContactInfo conInfo = new ContactInfo(con);
        return conInfo;
    }

    @AuraEnabled
    public static void saveContactInfo(String conInfo) {
        if(conInfo!=null){
            ContactInfo conObj = (ContactInfo)JSON.deserialize(conInfo, ContactInfo.class);
            Id userContactId = [select Id, contactId from User where Id = : UserInfo.getUserId()].contactId;
            Contact con = [select Id,MailingStreet, MailingCity, MailingState, MailingCountry, MailingAddress,MailingPostalcode ,Organization__c,Mailing_International_Address__c,Mailing_Address_Format__c from Contact where Id=:userContactId];
            con.Organization__c = conObj.organization;
            con.MailingStreet = conObj.street;
            con.MailingCity = conObj.city;
            con.MailingState = conObj.state;
            con.MailingCountry = conObj.country;
            con.MailingPostalcode = conObj.zip;
            con.Mailing_International_Address__c = conObj.internationalAddr;
            con.Mailing_Address_Format__c = conObj.addressFormat;
            update con;
        }
    }

    public without sharing class ContactInfo{
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String organization {get; set;}
        @AuraEnabled public String street {get; set;}
        @AuraEnabled public String city {get; set;}
        @AuraEnabled public String state {get; set;}
        @AuraEnabled public String country {get; set;}
        @AuraEnabled public String zip {get; set;}
        @AuraEnabled public String internationalAddr {get; set;}
        @AuraEnabled public String addressFormat {get; set;}

        public ContactInfo(Contact conObj){
            this.Id = conObj.Id;
            this.street = conObj.MailingStreet;
            this.city = conObj.MailingCity;
            this.state = conObj.MailingState;
            this.country = conObj.MailingCountry;
            this.zip = conObj.MailingPostalcode;
            this.organization = conObj.Organization__c;
            this.internationalAddr = conObj.Mailing_International_Address__c;
            this.addressFormat = conObj.Mailing_Address_Format__c;
        }
    }
}