import { LightningElement } from 'lwc';
export default class EmbedVflwc extends LightningElement {
    vfRoot = "https://ctds--sapdev001--c.sandbox.vf.force.com";
    iFrameURL = "https://ctds--sapdev001--c.sandbox.vf.force.com/apex/LWCWithVFPage";
    Name = '';
    City = '';
    messageFromVF;

    connectedCallback() {
        window.addEventListener("message", (message) => {
            console.log(message.origin);
            if (message.origin !== this.vfRoot) {
                //Not the expected origin
                return;
            }

            //handle the message
            if (message.data.name == "EmbedVflwc") {
                this.messageFromVF = message.data.payload;
                console.log(this.messageFromVF);
            }
        });
    }

    handleName(event) {
        this.Name = event.detail.value;
    }

    handleCity(event) {
        this.City = event.detail.value;
    }

    callVFPageMethod() {
        var vfWindow = this.template.querySelector("iframe").contentWindow;
        let paramData = { Name: this.Name, City: this.City };
        vfWindow.postMessage(paramData, this.vfRoot);
    }
}