/* eslint-disable no-console */
import { LightningElement, api } from "lwc";
import { insertRecord } from "c/genericAnalyticsRecord";
import { isUndefinedOrNull } from "c/appUtility";
import naicsCode from "@salesforce/label/c.checkListPage_naicsCode";
import naicsSubCode from "@salesforce/label/c.checkListPage_naicsSubCode";

export default class CheckListNaics extends LightningElement {
  @api naicsdetails;
  questionnaireId;
  label = {
    naicsCode,
    naicsSubCode
  };
  
  connectedCallback() {
		this.questionnaireId = new URL(document.location.href).searchParams.get("c__parentObjId");
	
		setTimeout(() => {
			this.renderRTEText();
		}, 800);
	}

  renderRTEText() {
		let ele = this.template.querySelector('.' + this.naicsdetails.subsectionId);
		
		if (ele) {
			ele.innerHTML = this.naicsdetails.rteText;
			ele.classList.add('itemText large paddingBtm');
		}
	}

	handleRichTextClick(event) {
		if(!isUndefinedOrNull(event.target.getAttribute("href"))) {
			this.insertAnalyticsEvent("Business registration", event.target.getAttribute("href"), event.target.textContent);
		} else if(!isUndefinedOrNull(event.target.parentNode.getAttribute("href"))) {
			this.insertAnalyticsEvent("Business registration", event.target.parentNode.getAttribute("href"), event.target.textContent);
    }
	}

	insertAnalyticsEvent(sectiontitle, targetLink, targetText) {
		insertRecord(
			this.questionnaireId, 
			"Checklist Generated Page", 
			sectiontitle, 
			"",
			"BusinessChecklist",
			"Link Click",
			targetLink,
			targetText,
			new Date().getTime(),
			""
		);
	}
}