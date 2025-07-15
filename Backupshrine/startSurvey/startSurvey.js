import { LightningElement, track } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import surveyLink from "@salesforce/label/c.surveyLink";
import survey_header from "@salesforce/label/c.survey_header";
import survey_content from "@salesforce/label/c.survey_content";
import start_survey from "@salesforce/label/c.start_survey";
export default class StartSurvey extends LightningElement {
  @track closeIcon = assetFolder + "/icons/close-outline.svg";
  @track startSurvey = assetFolder + "/icons/startSurvey.png";
  //setting labels to be used in HTML
  label = {
    surveyLink,
    survey_header,
    survey_content,
    start_survey
  };
  handleClose() {
    const closesurvey = new CustomEvent("closesurvey", {
      detail: false
    });
    this.dispatchEvent(closesurvey);
  }
}