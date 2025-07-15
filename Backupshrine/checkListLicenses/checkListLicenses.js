import { LightningElement, api } from "lwc";
import { insertRecord } from "c/genericAnalyticsRecord";
import { isUndefinedOrNull } from "c/appUtility";

export default class CheckListLicenses extends LightningElement {
  @api licenses;
  questionnaireId;

	connectedCallback() {
		this.questionnaireId = new URL(document.location.href).searchParams.get("c__parentObjId");
		
		setTimeout(() => {
			this.renderRTEText();
		}, 800);
	}

	renderRTEText() {
		let ele = this.template.querySelector('.' + this.licenses.subsectionId);
		let self = this;
		let l_index = 0;
		
		if (ele) {
			ele.innerHTML = this.licenses.rteText;
			ele.classList.add('itemText');
		}

		const elms = this.template.querySelectorAll('.license-details');
		this.template.querySelectorAll('.license-details').forEach(elm => {
			elm.innerHTML = self.licenses.dynamicData[l_index].licenseDetails;
			l_index += 1;
		});
	}

	handleRichTextClick(event) {
		if(!isUndefinedOrNull(event.target.getAttribute("href"))) {
			this.insertAnalyticsEvent("Licenses", event.target.getAttribute("href"), event.target.textContent);
		} else if(!isUndefinedOrNull(event.target.parentNode.getAttribute("href"))) {
			this.insertAnalyticsEvent("Licenses", event.target.parentNode.getAttribute("href"), event.target.textContent);
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