import { LightningElement, api, track  } from 'lwc';
import Cookie_Session_Time from "@salesforce/label/c.Cookie_Session_Time";
import ReviewSectionName from "@salesforce/label/c.ReviewSectionName";
import { isUndefinedOrNull } from "c/appUtility";
import updateQuestionnaire from "@salesforce/apex/Wizard_Utlity.updateQuestionnaire";
import { ComponentErrorLoging } from "c/formUtility";

/**This method stores the data in localstorage and sessionStorage for further use */
const setCookies = (parentRecordID) => {
    var d = new Date();
    d.setTime(d.getTime() + Cookie_Session_Time);
    var expires = "expires=" + d.toUTCString();
    document.cookie = 'appid =' + parentRecordID + ";" + expires + ";path=/";
}

const setLangaugeCookies  = (language) => {
    var d = new Date();
    d.setTime(d.getTime() + (Cookie_Session_Time));
    var expires = "expires=" + d.toUTCString();
    document.cookie = 'ctsessionlanguage=' + language + ";" + expires + ";path=/";
}

export {
    setCookies,setLangaugeCookies,updateflowsectionCount,addReviewSection,
}


const addReviewSection = (flowConfig)=>{
    if (flowConfig.reviewSectionRequired) {
        let sectionData = JSON.parse(
            JSON.stringify(
              flowConfig.sections[flowConfig.sections.length - 1]
            )
        );

        sectionData.title = ReviewSectionName;

        flowConfig.sections.push(
            JSON.parse(JSON.stringify(sectionData))
        );

        return flowConfig;
    }
}
const updateflowsectionCount=(localQuestionnaire,parentRecordID,compName)=>{
    if (!isUndefinedOrNull(localQuestionnaire) && !isUndefinedOrNull(parentRecordID)) {
        updateQuestionnaire({
            questionnaire: localQuestionnaire
        })
            .then(data => {
            })
            .catch(error => {
                ComponentErrorLoging(compName, 'updateSectionCount', '', '', 'Medium', error.message);
            });
    }
}

export default class FlowcontainergenericComponent extends LightningElement {   
    label = {
        Cookie_Session_Time
    };
}