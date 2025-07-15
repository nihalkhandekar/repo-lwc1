import { ComponentErrorLoging } from "c/formUtility";
import insertAnalyticsRecord from "@salesforce/apex/AnalyticsServiceClass.insertAnalyticsRecord";
import FORM_FACTOR from '@salesforce/client/formFactor';
import USER_ID from '@salesforce/user/Id';

const insertRecord = (Questionnaire, Section, Subsection, Response, Community_Page_Name, Event_Type, External_Link, Link_Name, Event_Start_Time, Event_Stop_Time) => {
    let AnalyticsEventRecord = {
        Questionnaire__c : Questionnaire,
        Section__c: Section,
        Subsection__c: Subsection,
        Response__c : Response,
        Community_Page_Name__c : Community_Page_Name,
        Event_Type__c : Event_Type,
        External_Link__c : External_Link,
        Link_Name__c : Link_Name,
        Event_Start_Time__c : Event_Start_Time,
        Event_Stop_Time__c : Event_Stop_Time,
        Time_Spent_on_Page_Seconds__c : (Event_Stop_Time !=="") ? ((Event_Stop_Time - Event_Start_Time) / 1000) : "",
        Device_Type__c : FORM_FACTOR
    };
	
    insertAnalyticsRecord({
    responses: JSON.stringify(AnalyticsEventRecord)
    })
    .then(result => {
        
    })
    .catch(error => {
        ComponentErrorLoging(
            "genericAnalyticsRecord",
            "insertAnalyticsRecord",
            "",
            "",
            "Medium",
            error.message
        );
    })
};

const insertAnalytics = (insertObj) => {
    if (!document.body.classList.contains("has-form-error")) {
        const endTime = new Date().getTime();       
        document.dispatchEvent(new CustomEvent("updateGTMdataLayer", {
            "detail": {
                event: {
                    event: "next-btn-click",
                    userId: USER_ID,
                    flowName: insertObj.flowName,
                    questionLabel: insertObj.questionLabel,
                    timeSpent: (endTime - insertObj.startTime) / 1000
                }
            }
        }));
    }
}

export {
    insertRecord,
    insertAnalytics
};