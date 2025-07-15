import { LightningElement , api, track} from 'lwc';
import learnMore from "@salesforce/label/c.Learn_More";

export default class LearnMore extends LightningElement {
    @api pagename;
    @track findyourbiz = false;
    @track matchcred = false;
    @track credconfirm = false;
    @track credsearch = false;
    @track linkcred = false;
    @track showHelp = false;

    @track label = {
        learnMore
    };

    connectedCallback(){
        if(this.pagename == 'findyourbiz'){
            this.findyourbiz = true;
        }
        else if(this.pagename == 'matchcred'){
            this.matchcred = true;
        }
        else if(this.pagename == 'credconfirm'){
            this.credconfirm = true;
        }
        else if(this.pagename == 'credsearch'){
            this.credsearch = true;
        }
        else if(this.pagename == 'linkcred'){
            this.linkcred = true;
        }
    }

    showDiv() {
        this.showHelp = !this.showHelp;
    }
}