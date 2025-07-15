import { api, LightningElement } from 'lwc';
import fivestarStyles from '@salesforce/resourceUrl/fivestarStyles';
import fivestarScripts from '@salesforce/resourceUrl/fivestarScripts';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

const ERROR_TITLE = 'Error loading five-star';
const EDITABLE_CLASS = 'c-rating';
const READ_ONLY_CLASS = 'readonly c-rating';

export default class FiveStarRating extends LightningElement {

    @api readOnly;
    @api value;

    editedValue;
    isRendered;

    get starClass() { return this.readOnly ? READ_ONLY_CLASS : EDITABLE_CLASS }

    renderedCallback() {
        if (this.isRendered) {
            return;
        }
        this.loadScript();
        this.isRendered = true;
    }

    loadScript() { 
        loadStyle(this, fivestarStyles).then(() => {
            console.log('loaded fivestar styles');
        })
        .catch(() => {
            console.log(ERROR_TITLE + ': ' + error.body.message);
        });
        loadScript(this, fivestarScripts).then(() => {
            this.initializeRating();
        })
        .catch(error => {
            console.log(ERROR_TITLE + ': ' + error.body.message);
        });
    }

    initializeRating() {
        let domEl = this.template.querySelector('ul');
        let maxRating = 5;
        let self = this;
        let callback = function (rating) {
            self.editedValue = rating;
            self.ratingChanged(rating);
        };
        this.ratingObj = window.rating(
            domEl,
            this.value,
            maxRating,
            callback,
            this.readOnly
        );
    }

    ratingChanged(rating) { 
        let CURRENT_RATING = rating;
        const custEvent = new CustomEvent('ratingchange', { detail: { rating: CURRENT_RATING } });
        this.dispatchEvent(custEvent);
    }
}